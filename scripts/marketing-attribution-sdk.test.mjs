import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { createServer } from "node:http";
import { test } from "node:test";
import { setTimeout as delay } from "node:timers/promises";
import { JSDOM } from "jsdom";
import { gunzipSync } from "node:zlib";

const sdk = readFileSync(
  new URL(
    "../node_modules/posthog-js/dist/array.full.no-external.js",
    import.meta.url,
  ),
  "utf8",
);
const attribution = readFileSync(
  new URL(
    "../app/frontend/components/marketingAttribution.js",
    import.meta.url,
  ),
  "utf8",
).replace(
  "export function initMarketingAttribution()",
  "function initMarketingAttribution()",
);

async function waitFor(predicate, message, timeout = 10000) {
  const deadline = Date.now() + timeout;
  while (!predicate() && Date.now() < deadline) await delay(20);
  assert.ok(predicate(), message);
}

test("bundled SDK preserves queued docs events without loading vendor scripts", async (t) => {
  const analytics = readFileSync(
    new URL("../app/views/application/_analytics.html.erb", import.meta.url),
    "utf8",
  );
  const initializer = [
    ...analytics.matchAll(
      /<%= javascript_tag nonce: true do %>([\s\S]*?)<% end %>/g,
    ),
  ]
    .map((match) => match[1])
    .find((script) => script.includes("posthog.init("));
  const dom = new JSDOM("<script></script>", {
    url: "https://example.com/docs",
    runScripts: "outside-only",
    pretendToBeVisual: true,
  });
  t.after(() => dom.window.close());
  const { window } = dom;
  window.eval(initializer);
  window.posthog.capture("docs:page_feedback", { rating: 4 });
  assert.equal(window.document.querySelectorAll("script[src]").length, 0);

  const requests = [];
  Object.assign(window, { Headers, Response });
  window.fetch = async (url) => {
    requests.push(String(url));
    const response = String(url).includes("/api/surveys/")
      ? { surveys: [] }
      : {
          hasFeatureFlags: false,
          supportedCompression: ["gzip-js"],
          sessionRecording: { endpoint: "/s/", sampleRate: 1 },
          surveys: true,
        };
    return new Response(JSON.stringify(response), {
      headers: { "Content-Type": "application/json" },
    });
  };
  const events = [];
  window.posthog._i[0][1] = {
    ...window.posthog._i[0][1],
    request_batching: false,
    api_transport: "fetch",
    before_send: (event) => {
      events.push(event);
      return null;
    },
  };
  window.eval(sdk);
  window.posthog.capture("docs_search_query", { query: "pipeline" });
  await waitFor(
    () => events.some((event) => event.event === "$pageview"),
    "automatic pageview is captured",
  );
  await waitFor(
    () => window.posthog.sessionRecordingStarted(),
    "bundled recorder starts from remote JSON configuration",
  );
  assert.ok(
    requests.some((url) => new URL(url).pathname.endsWith("/config")),
    "remote configuration is fetched as data",
  );

  const feedback = events.find((event) => event.event === "docs:page_feedback");
  assert.equal(feedback.properties.rating, 4);
  assert.equal(feedback.properties.app, "docs");
  const search = events.find((event) => event.event === "docs_search_query");
  assert.equal(search.properties.query, "pipeline");
  assert.equal(search.properties.app, "docs");
  assert.equal(events.filter((event) => event.event === "$pageview").length, 1);
  assert.equal(window.posthog.config.defaults, "2026-01-30");
  assert.equal(window.document.querySelectorAll("script[src]").length, 0);
});

test("real SDK cancels old retries and recovers across consent cycles", async (t) => {
  let fail = true;
  let received = 0;
  const attempts = [];
  let beaconCalls = 0;
  const deliveries = [];
  const server = createServer((request, response) => {
    const chunks = [];
    request.on("data", (chunk) => chunks.push(chunk));
    request.on("end", () => {
      if (request.method === "POST") {
        received++;
        const body = Buffer.concat(chunks);
        const payload = JSON.parse(gunzipSync(body).toString());
        deliveries.push(
          ...(Array.isArray(payload) ? payload : payload.batch || [payload]),
        );
      }
      response.writeHead(request.method === "POST" && fail ? 503 : 200, {
        "Content-Type": "application/json",
      });
      response.end(
        JSON.stringify({
          hasFeatureFlags: false,
          supportedCompression: ["gzip-js"],
        }),
      );
    });
  });
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  t.after(() => new Promise((resolve) => server.close(resolve)));
  const host = `http://127.0.0.1:${server.address().port}`;
  const dom = new JSDOM('<a href="/signup">Signup</a>', {
    url: "https://buildkite.com/docs?utm_source=linkedin&utm_campaign=consent-test",
    runScripts: "outside-only",
  });
  t.after(() => dom.window.close());
  const { window } = dom;
  Object.assign(window, { AbortController, Headers, Response });
  window.fetch = (url, options) => {
    if (options.method === "POST") {
      attempts.push({
        url,
        signal: options.signal,
        aborted: options.signal?.aborted,
      });
    }
    return fetch(url, options);
  };
  // Any fallback to a beacon is a test failure, including during unload.
  window.navigator.sendBeacon = () => {
    beaconCalls++;
    return false;
  };
  window.posthog = [];
  window.eval(sdk);
  window.posthog.init("qa_docs", {
    api_host: host,
    capture_pageview: false,
    autocapture: false,
    advanced_disable_feature_flags: true,
    disable_session_recording: true,
  });
  window.eval(
    attribution.replace('"https://us.i.posthog.com"', JSON.stringify(host)),
  );
  window.initMarketingAttribution();

  await waitFor(() => received > 0, "initial event reached collector");
  // Control: real SDK retry, not a manually invoked before_send callback.
  await waitFor(
    () => attempts.some(({ url }) => url.includes("retry_count=")),
    "failed request retries with consent",
  );
  let oldSignal = attempts[0].signal;
  for (let cycle = 0; cycle < 2; cycle++) {
    const client = window.posthog.marketing;
    const oldAttempts = attempts.filter(
      (attempt) => attempt.signal === oldSignal,
    ).length;
    window.posthog.opt_out_capturing();
    assert.equal(client.has_opted_out_capturing(), true);
    assert.equal(oldSignal.aborted, true);
    assert.ok(
      !window.document.cookie.includes("bk_marketing_tracking_allowed="),
    );
    assert.equal(
      window.document.querySelector("a").getAttribute("href"),
      "/signup",
    );
    await delay(50);
    const beforeResume = received;
    const previousDeliveries = deliveries.length;
    fail = false;
    window.posthog.opt_in_capturing({ captureEventName: false });
    window.initMarketingAttribution();
    assert.equal(
      window.posthog.marketing,
      client,
      "Marketing opt-out must still block renewal",
    );
    assert.ok(
      !window.document.cookie.includes("bk_marketing_tracking_allowed="),
    );
    client.opt_in_capturing({ captureEventName: false });
    window.history.pushState({}, "", `/docs/pipelines?cycle=${cycle}`);
    window.initMarketingAttribution();
    await waitFor(
      () => received > beforeResume,
      "newly consented navigation reaches collector",
    );
    assert.notEqual(window.posthog.marketing, client);
    assert.equal(window.posthog.marketing.has_opted_out_capturing(), false);
    assert.ok(
      window.document.cookie.includes("bk_marketing_tracking_allowed=1"),
    );
    const newSignal = attempts.at(-1).signal;
    assert.notEqual(newSignal, oldSignal);
    assert.equal(newSignal.aborted, false);
    assert.equal(oldSignal.aborted, true);
    // The contract is network delivery, not whether the SDK drops or retries its
    // queue. Wait beyond the first retry window and inspect actual collector data.
    await delay(9500);
    assert.deepEqual(
      deliveries.slice(previousDeliveries).map((event) => ({
        event: event.event,
        url: event.properties.$current_url,
      })),
      [{ event: "$pageview", url: window.location.href }],
      "only the newly consented navigation is delivered; no old event is replayed",
    );
    assert.ok(
      attempts
        .filter((attempt) => attempt.signal === oldSignal)
        .slice(oldAttempts)
        .every((attempt) => attempt.aborted),
    );
    assert.equal(
      received,
      beforeResume + 1,
      "only the new pageview reached collector",
    );
    assert.equal(beaconCalls, 0, "no non-cancellable beacon fallback");
    // Leave another failed request queued for the next withdrawal cycle.
    fail = true;
    window.posthog.marketing.capture("qa_retry_probe");
    await waitFor(
      () => received > beforeResume + 1,
      "next failed event reached collector",
    );
    await delay(50);
    oldSignal = newSignal;
  }
});
