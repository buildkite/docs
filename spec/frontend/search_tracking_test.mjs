import assert from "node:assert/strict";
import { test } from "node:test";
import {
  searchTrackingClient,
  searchTrackingItems,
} from "../../app/frontend/components/searchTracking.js";

test("tracks queries from current and legacy DocSearch requests", async (t) => {
  t.mock.timers.enable({ apis: ["setTimeout"] });
  const events = [];
  globalThis.window = {
    location: { href: "https://example.com/docs", pathname: "/docs" },
  };
  globalThis.posthog = {
    capture: (event, properties) => events.push({ event, properties }),
  };
  t.after(() => {
    delete globalThis.window;
    delete globalThis.posthog;
  });

  for (const request of [
    { requests: [{ indexName: "docs", query: "pipeline" }] },
    [{ indexName: "docs", query: "pipeline" }],
    [{ indexName: "docs", params: { query: "pipeline" } }],
  ]) {
    const response = { results: [{ hits: [{}, {}], nbHits: 50 }] };
    const client = searchTrackingClient({
      search: async (received) => {
        assert.equal(received, request);
        return response;
      },
    });
    const pending = client.search(request);
    t.mock.timers.tick(250);
    assert.equal(await pending, response);
    searchTrackingItems(response.results[0].hits);
    events.length = 0;

    t.mock.timers.tick(999);
    assert.equal(events.length, 0);
    t.mock.timers.tick(1);
    assert.equal(events.length, 1);
    assert.equal(events[0].event, "docs_search_query");
    assert.equal(events[0].properties.query, "pipeline");
    assert.equal(events[0].properties.result_count, 2);
  }
});
