import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import vm from "node:vm";

const source = readFileSync(
  new URL(
    "../app/frontend/components/marketingAttribution.js",
    import.meta.url,
  ),
  "utf8",
)
  .replace(
    "export function initMarketingAttribution()",
    "function initMarketingAttribution()",
  )
  .concat(
    "\nwindow.__initMarketingAttribution = initMarketingAttribution;",
    "\nwindow.__readMarketingAttribution = typeof readAttribution === 'function' ? readAttribution : undefined;",
  );

const linkedInClickId = "00000000-0000-4000-8000-000000000001";

function createAnchor(href, analyticsLocation = "") {
  const attributes = new Map([["href", href]]);
  const locationElement = analyticsLocation
    ? {
        getAttribute(name) {
          return name === "data-analytics-location" ? analyticsLocation : null;
        },
      }
    : null;

  return {
    nodeType: 1,
    tagName: "A",
    dataset: {},
    getAttribute(name) {
      return attributes.get(name) ?? null;
    },
    setAttribute(name, value) {
      attributes.set(name, value);
    },
    removeAttribute(name) {
      attributes.delete(name);
    },
    hasAttribute(name) {
      return attributes.has(name);
    },
    closest(selector) {
      if (selector === "a[href]") return this;
      if (selector === "[data-analytics-location]") return locationElement;
      return null;
    },
    querySelectorAll() {
      return [];
    },
  };
}

function runAttribution({
  url,
  cookieJar = new Map(),
  anchors = [],
  docsDistinctId = "docs-anonymous-id",
  marketingDistinctId = "marketing-anonymous-id",
  docsReady = true,
  marketingOptedOut = false,
  optedOut = false,
  referrer = "",
  beaconAvailable = true,
  fetchAvailable = true,
  abortControllerAvailable = true,
} = {}) {
  const listeners = new Map();
  const marketingCaptures = [];
  const marketingInitCalls = [];
  const marketingOptOutCalls = [];
  let marketingConfig;
  const docsOptOutCalls = [];
  const timers = [];
  const location = new URL(url);
  let docsIsReady = docsReady;
  let docsIsOptedOut = optedOut;
  let marketingIsOptedOut = marketingOptedOut || optedOut;

  const document = {
    body: {},
    documentElement: {},
    readyState: "complete",
    referrer,
    addEventListener(name, listener) {
      listeners.set(name, listener);
    },
    querySelectorAll(selector) {
      if (selector === "a[href]") return anchors;
      if (selector.includes("data-bk-utm-rewritten")) {
        return anchors.filter(
          (anchor) => anchor.getAttribute("data-bk-utm-rewritten") === "1",
        );
      }
      return [];
    },
  };

  Object.defineProperty(document, "cookie", {
    get() {
      return [...cookieJar.entries()]
        .map(([name, value]) => `${name}=${value}`)
        .join("; ");
    },
    set(serialized) {
      const [pair] = serialized.split(";");
      const separator = pair.indexOf("=");
      const name = pair.slice(0, separator);
      if (/max-age=0/i.test(serialized)) {
        cookieJar.delete(name);
      } else {
        cookieJar.set(name, pair.slice(separator + 1));
      }
    },
  });

  const marketing = {
    opt_in_capturing() {
      marketingIsOptedOut = false;
    },
    capture(name, properties) {
      if (!marketingIsOptedOut) marketingCaptures.push({ name, properties });
    },
    get_distinct_id() {
      return marketingDistinctId;
    },
    has_opted_out_capturing() {
      return marketingIsOptedOut;
    },
    opt_out_capturing() {
      marketingIsOptedOut = true;
      marketingOptOutCalls.push(true);
    },
    register() {},
    unregister() {},
  };

  const posthogMethods = {
    opt_in_capturing() {
      docsIsOptedOut = false;
    },
    opt_out_capturing(...args) {
      docsIsOptedOut = true;
      docsOptOutCalls.push({ receiver: this, args });
      return "docs-opted-out";
    },
    get_distinct_id() {
      return docsDistinctId;
    },
    has_opted_out_capturing() {
      return docsIsOptedOut;
    },
    init(_token, config, name) {
      marketingConfig = config;
      marketingInitCalls.push({ config, name, token: _token });
      config.loaded?.(marketing);
      this[name] = marketing;
      return marketing;
    },
  };
  const posthog = docsIsReady ? { ...posthogMethods } : {};

  const window = {
    addEventListener(name, listener) {
      listeners.set(name, listener);
    },
    location,
    navigator: { sendBeacon: beaconAvailable ? () => true : undefined },
    fetch: fetchAvailable ? () => Promise.resolve() : undefined,
    AbortController: abortControllerAvailable ? AbortController : undefined,
    posthog,
    setTimeout(callback) {
      if (docsIsReady) callback();
      else timers.push(callback);
      return timers.length;
    },
  };

  vm.runInNewContext(source, {
    Date,
    MutationObserver: undefined,
    URL,
    URLSearchParams,
    document,
    setTimeout: window.setTimeout,
    window,
  });

  window.__initMarketingAttribution();

  return {
    cookieJar,
    get marketingConfig() {
      return marketingConfig;
    },
    restoreConsent() {
      posthog.opt_in_capturing();
      marketing.opt_in_capturing();
    },
    dispatchClick(target) {
      listeners.get("click")?.({ target });
    },
    decodedCookie(name) {
      const value = cookieJar.get(name);
      return value ? decodeURIComponent(value) : "";
    },
    marketingCaptures,
    marketingInitCalls,
    marketingOptOutCalls,
    docsOptOutCalls,
    makeDocsPostHogReady() {
      docsIsReady = true;
      Object.assign(posthog, posthogMethods);
      while (timers.length) timers.shift()();
    },
    readAttribution: window.__readMarketingAttribution,
    reinitialize(nextUrl) {
      if (nextUrl) window.location = new URL(nextUrl);
      window.__initMarketingAttribution();
    },
    withdrawDocsConsent(...args) {
      return posthog.opt_out_capturing(...args);
    },
  };
}

test("preserves an existing canonical marketing identity", () => {
  const cookieJar = new Map([
    ["bk_marketing_id", encodeURIComponent("canonical-marketing-id")],
  ]);

  const result = runAttribution({
    url: "https://buildkite.com/docs",
    cookieJar,
    docsDistinctId: "docs-project-id",
    marketingDistinctId: "different-marketing-id",
  });

  assert.equal(
    result.decodedCookie("bk_marketing_id"),
    "canonical-marketing-id",
  );
});

test("rejects malformed LinkedIn click IDs", () => {
  const anchor = createAnchor("/signup?iaid=pricing-free");
  const result = runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin&li_fat_id=not-a-uuid",
    anchors: [anchor],
  });

  const lastTouch = new URLSearchParams(result.decodedCookie("bk_last_touch"));
  assert.equal(lastTouch.get("li_fat_id"), null);
  assert.equal(
    new URL(anchor.getAttribute("href")).searchParams.get("li_fat_id"),
    null,
  );
});

test("exposes version 2 first-touch and last-touch attribution", () => {
  const result = runAttribution({
    url: `https://buildkite.com/docs?utm_source=LinkedIn&utm_medium=Paid_Social&utm_campaign=docs_test&li_fat_id=${linkedInClickId}`,
  });

  assert.equal(typeof result.readAttribution, "function");
  const attribution = result.readAttribution();
  assert.equal(attribution.attribution_version, "2");
  assert.equal(attribution.first_touch_utm_source, "linkedin");
  assert.equal(attribution.last_touch_utm_medium, "paid_social");
  assert.equal(attribution.last_touch_li_fat_id, linkedInClickId);
  assert.equal(attribution.marketing_attribution_id, "marketing-anonymous-id");
});

test("captures and forwards the standard campaign parameters", () => {
  const anchor = createAnchor("/signup?iaid=pricing-free");
  const result = runAttribution({
    url: `https://buildkite.com/docs?utm_source=linkedin&utm_medium=paid_social&utm_campaign=docs_launch&utm_content=video_v1&utm_term=high_intent&utm_id=campaign_123&li_fat_id=${linkedInClickId}`,
    anchors: [anchor],
  });

  const destination = new URL(anchor.getAttribute("href"));
  assert.equal(destination.searchParams.get("utm_source"), "linkedin");
  assert.equal(destination.searchParams.get("utm_medium"), "paid_social");
  assert.equal(destination.searchParams.get("utm_campaign"), "docs_launch");
  assert.equal(destination.searchParams.get("utm_content"), "video_v1");
  assert.equal(destination.searchParams.get("utm_term"), "high_intent");
  assert.equal(destination.searchParams.get("utm_id"), "campaign_123");
  assert.equal(destination.searchParams.get("li_fat_id"), linkedInClickId);
  assert.equal(destination.searchParams.get("iaid"), "pricing-free");
  assert.ok(result.decodedCookie("bk_last_touch"));
});

test("preserves first touch while a later campaign updates last touch", () => {
  const cookieJar = new Map();
  runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin&utm_campaign=first_campaign",
    cookieJar,
  });
  const result = runAttribution({
    url: "https://buildkite.com/docs?utm_source=google&utm_campaign=later_campaign",
    cookieJar,
  });

  const attribution = result.readAttribution();
  assert.equal(attribution.first_touch_utm_source, "linkedin");
  assert.equal(attribution.first_touch_utm_campaign, "first_campaign");
  assert.equal(attribution.last_touch_utm_source, "google");
  assert.equal(attribution.last_touch_utm_campaign, "later_campaign");
});

test("retains a LinkedIn first touch through a later direct visit", () => {
  const cookieJar = new Map();
  runAttribution({
    url: `https://buildkite.com/docs?utm_source=linkedin&li_fat_id=${linkedInClickId}`,
    cookieJar,
  });
  const result = runAttribution({
    url: "https://buildkite.com/docs/pipelines",
    cookieJar,
  });

  const attribution = result.readAttribution();
  assert.equal(attribution.first_touch_li_fat_id, linkedInClickId);
  assert.equal(attribution.last_touch_li_fat_id, linkedInClickId);
});

test("adds the LinkedIn cookie ID to a tagged landing without a URL ID", () => {
  const cookieJar = new Map([
    ["li_fat_id", encodeURIComponent(linkedInClickId)],
  ]);
  const anchor = createAnchor("/signup?iaid=pricing-free");
  const result = runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin&utm_campaign=docs_launch",
    cookieJar,
    anchors: [anchor],
  });

  const attribution = result.readAttribution();
  const destination = new URL(anchor.getAttribute("href"));
  assert.equal(attribution.last_touch_li_fat_id, linkedInClickId);
  assert.equal(destination.searchParams.get("li_fat_id"), linkedInClickId);
});

test("preserves the campaign after Turbo navigation with a LinkedIn referrer", () => {
  const cookieJar = new Map([
    ["li_fat_id", encodeURIComponent(linkedInClickId)],
  ]);
  const result = runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin&utm_campaign=docs_launch",
    cookieJar,
    referrer: "https://www.linkedin.com/feed/",
  });

  result.reinitialize("https://buildkite.com/docs/pipelines");

  const attribution = result.readAttribution();
  assert.equal(attribution.last_touch_utm_source, "linkedin");
  assert.equal(attribution.last_touch_utm_campaign, "docs_launch");
  assert.equal(attribution.last_touch_li_fat_id, linkedInClickId);
});

test("preserves a pending landing campaign when Turbo navigates before PostHog loads", () => {
  const signup = createAnchor("/signup?iaid=docs-header");
  const result = runAttribution({
    url: `https://buildkite.com/docs?utm_source=linkedin&utm_medium=paid_social&utm_campaign=docs_launch&li_fat_id=${linkedInClickId}`,
    anchors: [signup],
    docsReady: false,
    referrer: "https://www.linkedin.com/feed/",
  });

  result.reinitialize("https://buildkite.com/docs/pipelines");
  result.makeDocsPostHogReady();
  result.reinitialize();

  const attribution = result.readAttribution();
  const destination = new URL(
    signup.getAttribute("href"),
    "https://buildkite.com",
  );
  assert.equal(attribution.last_touch_utm_source, "linkedin");
  assert.equal(attribution.last_touch_utm_campaign, "docs_launch");
  assert.equal(attribution.last_touch_li_fat_id, linkedInClickId);
  assert.equal(destination.searchParams.get("utm_campaign"), "docs_launch");
  assert.equal(destination.searchParams.get("li_fat_id"), linkedInClickId);
});

test("recovers safely from malformed attribution cookies", () => {
  const cookieJar = new Map([
    ["bk_first_touch", "%"],
    ["bk_last_touch", "%"],
    ["bk_marketing_id", "%"],
  ]);
  const result = runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin",
    cookieJar,
  });

  const attribution = result.readAttribution();
  assert.equal(attribution.first_touch_utm_source, "linkedin");
  assert.equal(attribution.last_touch_utm_source, "linkedin");
  assert.equal(attribution.marketing_attribution_id, "marketing-anonymous-id");
});

test("captures one Docs pageview in the marketing project", () => {
  const result = runAttribution({
    url: `https://buildkite.com/docs?utm_source=linkedin&li_fat_id=${linkedInClickId}`,
  });

  assert.deepEqual(
    result.marketingCaptures.map(({ name }) => name),
    ["$pageview"],
  );
  assert.equal(
    result.marketingCaptures[0].properties.analytics_surface,
    "docs",
  );
  assert.equal(result.marketingCaptures[0].properties.attribution_version, "2");
});

test("bootstraps the named marketing instance with an existing canonical ID", () => {
  const cookieJar = new Map([
    ["bk_marketing_id", encodeURIComponent("canonical-marketing-id")],
  ]);
  const result = runAttribution({
    url: "https://buildkite.com/docs",
    cookieJar,
  });

  assert.equal(result.marketingInitCalls.length, 1);
  assert.equal(result.marketingInitCalls[0].name, "marketing");
  assert.equal(result.marketingInitCalls[0].config.persistence, "memory");
  assert.equal(result.marketingInitCalls[0].config.request_batching, false);
  assert.equal(result.marketingInitCalls[0].config.api_transport, "fetch");
  assert.equal(result.marketingInitCalls[0].config.capture_pageview, false);
  assert.deepEqual(
    JSON.parse(JSON.stringify(result.marketingInitCalls[0].config.bootstrap)),
    {
      distinctID: "canonical-marketing-id",
      isIdentifiedID: false,
    },
  );
});

test("does not duplicate a pageview when initialization runs twice for one URL", () => {
  const result = runAttribution({ url: "https://buildkite.com/docs" });

  result.reinitialize();

  assert.deepEqual(
    result.marketingCaptures.map(({ name }) => name),
    ["$pageview"],
  );
});

test("captures a new Docs pageview after Turbo navigation", () => {
  const result = runAttribution({ url: "https://buildkite.com/docs" });

  result.reinitialize("https://buildkite.com/docs/pipelines");

  assert.deepEqual(
    result.marketingCaptures.map(({ name }) => name),
    ["$pageview", "$pageview"],
  );
  assert.equal(
    result.marketingCaptures[1].properties.$pathname,
    "/docs/pipelines",
  );
});

test("captures signup CTA clicks with Docs attribution", () => {
  const anchor = createAnchor("/signup?iaid=pricing-free", "docs_header");
  const result = runAttribution({
    url: `https://buildkite.com/docs?utm_source=linkedin&li_fat_id=${linkedInClickId}`,
    anchors: [anchor],
  });

  result.dispatchClick(anchor);

  assert.deepEqual(
    result.marketingCaptures.map(({ name }) => name),
    ["$pageview", "signup_cta_click"],
  );
  assert.equal(
    result.marketingCaptures[1].properties.analytics_surface,
    "docs",
  );
  assert.equal(
    result.marketingCaptures[1].properties.cta_location,
    "docs_header",
  );
  assert.equal(
    result.marketingCaptures[1].properties.last_touch_li_fat_id,
    linkedInClickId,
  );
});

test("classifies an unlabeled signup CTA as inline content", () => {
  const anchor = createAnchor("/signup?iaid=pricing-free");
  const result = runAttribution({
    url: "https://buildkite.com/docs/pipelines/getting-started",
    anchors: [anchor],
  });

  result.dispatchClick(anchor);

  assert.equal(
    result.marketingCaptures[1].properties.cta_location,
    "inline_content",
  );
  assert.equal(
    result.marketingCaptures[1].properties.screen_name,
    "/docs/pipelines/getting-started",
  );
});

test("does not rewrite non-signup links", () => {
  const docsLink = createAnchor("/docs/pipelines");
  const externalLink = createAnchor("https://example.com/signup");
  const mailLink = createAnchor("mailto:user@example.com");
  const fragmentLink = createAnchor("#overview");

  runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin",
    anchors: [docsLink, externalLink, mailLink, fragmentLink],
  });

  assert.equal(docsLink.getAttribute("href"), "/docs/pipelines");
  assert.equal(externalLink.getAttribute("href"), "https://example.com/signup");
  assert.equal(mailLink.getAttribute("href"), "mailto:user@example.com");
  assert.equal(fragmentLink.getAttribute("href"), "#overview");
});

test("forwards the persisted campaign from Docs to signup", () => {
  const cookieJar = new Map();
  runAttribution({
    url: `https://buildkite.com/docs?utm_source=linkedin&utm_medium=paid_social&utm_campaign=docs_launch&li_fat_id=${linkedInClickId}`,
    cookieJar,
  });

  const signup = createAnchor("/signup?iaid=docs-header");
  runAttribution({
    url: "https://buildkite.com/docs/pipelines",
    cookieJar,
    anchors: [signup],
  });

  const destination = new URL(signup.getAttribute("href"));
  assert.equal(destination.pathname, "/signup");
  assert.equal(destination.searchParams.get("iaid"), "docs-header");
  assert.equal(destination.searchParams.get("utm_source"), "linkedin");
  assert.equal(destination.searchParams.get("utm_medium"), "paid_social");
  assert.equal(destination.searchParams.get("utm_campaign"), "docs_launch");
  assert.equal(destination.searchParams.get("li_fat_id"), linkedInClickId);
});

test("marks every marketing event as Docs attribution version 2", () => {
  const result = runAttribution({ url: "https://buildkite.com/docs" });
  const beforeSend = result.marketingInitCalls[0].config.before_send;
  const event = beforeSend({ properties: {} });

  assert.equal(event.properties.analytics_surface, "docs");
  assert.equal(event.properties.attribution_version, "2");
});

test("clears attribution and does not initialize marketing tracking after opt-out", () => {
  const cookieJar = new Map([
    ["bk_first_touch", encodeURIComponent("utm_source=linkedin")],
    ["bk_last_touch", encodeURIComponent("utm_source=linkedin")],
    ["bk_marketing_id", encodeURIComponent("canonical-marketing-id")],
    ["bk_marketing_tracking_allowed", "1"],
  ]);
  const result = runAttribution({
    url: "https://buildkite.com/docs",
    cookieJar,
    optedOut: true,
  });

  assert.equal(result.marketingInitCalls.length, 0);
  assert.equal(result.marketingCaptures.length, 0);
  assert.equal(result.decodedCookie("bk_first_touch"), "");
  assert.equal(result.decodedCookie("bk_last_touch"), "");
  assert.equal(result.decodedCookie("bk_marketing_id"), "");
  assert.equal(result.decodedCookie("bk_marketing_tracking_allowed"), "");
});

test("does not persist or forward attribution when Marketing PostHog is opted out", () => {
  const signup = createAnchor("/signup?iaid=docs-header");
  const result = runAttribution({
    url: `https://buildkite.com/docs?utm_source=linkedin&utm_campaign=docs_launch&li_fat_id=${linkedInClickId}`,
    anchors: [signup],
    marketingOptedOut: true,
  });

  assert.equal(result.marketingCaptures.length, 0);
  assert.equal(result.decodedCookie("bk_first_touch"), "");
  assert.equal(result.decodedCookie("bk_last_touch"), "");
  assert.equal(result.decodedCookie("bk_marketing_id"), "");
  assert.equal(result.decodedCookie("bk_marketing_tracking_allowed"), "");
  assert.equal(signup.getAttribute("href"), "/signup?iaid=docs-header");
});

test("withdrawing Docs consent opts out Marketing PostHog and removes attribution", () => {
  const signup = createAnchor("/signup?iaid=docs-header");
  const result = runAttribution({
    url: `https://buildkite.com/docs?utm_source=linkedin&utm_campaign=docs_launch&li_fat_id=${linkedInClickId}`,
    anchors: [signup],
  });

  result.withdrawDocsConsent();

  assert.equal(result.marketingOptOutCalls.length, 1);
  assert.equal(result.decodedCookie("bk_first_touch"), "");
  assert.equal(result.decodedCookie("bk_last_touch"), "");
  assert.equal(result.decodedCookie("bk_marketing_id"), "");
  assert.equal(result.decodedCookie("bk_marketing_tracking_allowed"), "");
  assert.equal(signup.getAttribute("href"), "/signup?iaid=docs-header");
});

test("drops Marketing events processed after Docs consent is withdrawn", () => {
  const result = runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin",
  });
  const beforeSend = result.marketingInitCalls[0].config.before_send;

  result.withdrawDocsConsent();

  assert.equal(beforeSend({ properties: {} }), null);
});

test("idle consent withdrawal restores signup links without navigation or reinitialization", () => {
  const signup = createAnchor("/signup?iaid=docs-header");
  const result = runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin&utm_medium=paid_social&utm_campaign=docs_launch",
    anchors: [signup],
  });
  assert.equal(result.decodedCookie("bk_marketing_tracking_allowed"), "1");
  result.withdrawDocsConsent();
  assert.equal(result.marketingOptOutCalls.length, 1);
  for (const name of [
    "bk_marketing_tracking_allowed",
    "bk_marketing_id",
    "bk_first_touch",
    "bk_last_touch",
  ]) {
    assert.equal(result.decodedCookie(name), "");
  }
  assert.equal(signup.getAttribute("href"), "/signup?iaid=docs-header");
});

test("consent observation preserves SDK arguments and return values across Turbo initialization", () => {
  const result = runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin",
  });
  result.reinitialize();
  result.reinitialize();
  const options = { clear_persistence: true };
  assert.equal(result.withdrawDocsConsent(options), "docs-opted-out");
  assert.equal(result.docsOptOutCalls.length, 1);
  assert.equal(result.docsOptOutCalls[0].args[0], options);
  assert.equal(result.marketingOptOutCalls.length, 1);
});

test("uses cancellable fetch when beacons are unavailable", () => {
  const result = runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin&utm_campaign=docs-test",
    beaconAvailable: false,
  });
  assert.equal(result.marketingInitCalls.length, 1);
  assert.equal(result.marketingInitCalls[0].config.disable_beacon, true);
});

test("withdrawal cancels the Marketing connection used by delayed retries", () => {
  const result = runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin",
  });
  const config = result.marketingInitCalls[0].config;
  const signal = config.fetch_options?.signal;
  assert.ok(signal, "Marketing requests must carry a cancellable signal");
  assert.equal(signal.aborted, false);
  result.withdrawDocsConsent();
  assert.equal(signal.aborted, true);
  result.reinitialize("https://buildkite.com/docs/pipelines");
  assert.equal(signal.aborted, true);
});

test("rejected beacons cannot select a non-cancellable Marketing fallback", () => {
  const result = runAttribution({
    url: "https://buildkite.com/docs",
    beaconAvailable: true,
  });
  const config = result.marketingInitCalls[0].config;
  assert.equal(config.api_transport, "fetch");
  assert.equal(config.disable_beacon, true);
  assert.equal(config.request_batching, false);
});

for (const unavailable of ["fetchAvailable", "abortControllerAvailable"]) {
  test(`does not initialize Marketing when ${unavailable} is false`, () => {
    const result = runAttribution({
      url: "https://buildkite.com/docs",
      [unavailable]: false,
    });
    assert.equal(result.marketingInitCalls.length, 0);
  });
}

test("consent recovery creates a new client without reviving old retries", () => {
  const result = runAttribution({
    url: "https://buildkite.com/docs?utm_source=linkedin",
  });
  const oldOptions = result.marketingConfig.fetch_options;
  result.withdrawDocsConsent();
  result.restoreConsent();
  result.reinitialize("https://buildkite.com/docs/pipelines");
  const newOptions = result.marketingConfig.fetch_options;
  assert.equal(result.marketingInitCalls.length, 2);
  assert.equal(result.marketingInitCalls[1].name, "marketing_consent_1");
  assert.notEqual(newOptions, oldOptions);
  assert.equal(oldOptions.signal.aborted, true);
  assert.equal(newOptions.signal.aborted, false);
  assert.equal(result.decodedCookie("bk_marketing_tracking_allowed"), "1");
  result.reinitialize("https://buildkite.com/docs/agent");
  assert.equal(result.marketingConfig.fetch_options, newOptions);
  result.withdrawDocsConsent();
  assert.equal(newOptions.signal.aborted, true);
});
