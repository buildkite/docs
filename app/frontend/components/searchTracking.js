/**
 * PostHog tracking for DocSearch interactions.
 *
 * Events:
 * - docs_search_opened: Search modal was opened
 * - docs_search_query: User searched (fires after 1s dwell or on modal close)
 * - docs_search_result_clicked: User clicked a search result
 * - docs_search_abandoned: User closed search without clicking a result
 */

const DWELL_MS = 1000;

let searchSessionActive = false;
let lastQuery = "";
let lastResultCount = 0;
let resultClicked = false;
let dwellTimer = null;

function capture(event, properties) {
  if (typeof posthog !== "undefined") {
    posthog.capture(event, {
      ...properties,
      page_url: window.location.href,
      page_path: window.location.pathname,
    });
  }
}

function onSearchOpen() {
  searchSessionActive = true;
  resultClicked = false;
  lastQuery = "";
  lastResultCount = 0;
  capture("docs_search_opened", {});
}

function onSearchClose() {
  // If the dwell timer was still pending, the last query hasn't been captured yet
  if (dwellTimer) {
    clearTimeout(dwellTimer);
    dwellTimer = null;
    if (lastQuery.length > 0) {
      capture("docs_search_query", {
        query: lastQuery,
        result_count: lastResultCount,
      });
    }
  }

  if (!resultClicked && lastQuery.length > 0) {
    capture("docs_search_abandoned", {
      query: lastQuery,
      result_count: lastResultCount,
    });
  }

  searchSessionActive = false;
}

/**
 * Observes body class changes to detect DocSearch modal open/close.
 * Returns a cleanup function to disconnect the observer.
 */
export function initSearchTracking() {
  const observer = new MutationObserver(() => {
    const isOpen = document.body.classList.contains("DocSearch--active");
    if (isOpen && !searchSessionActive) {
      onSearchOpen();
    } else if (!isOpen && searchSessionActive) {
      onSearchClose();
    }
  });

  observer.observe(document.body, {
    attributes: true,
    attributeFilter: ["class"],
  });

  return () => {
    if (dwellTimer) {
      clearTimeout(dwellTimer);
      dwellTimer = null;
    }
    observer.disconnect();
  };
}

/**
 * DocSearch transformSearchClient option.
 * Wraps the Algolia search client to capture queries with dwell-based debounce.
 */
export function searchTrackingClient(searchClient) {
  return {
    ...searchClient,
    search(queries) {
      return searchClient.search(queries).then((response) => {
        const query = Array.isArray(queries)
          ? queries[0]?.params?.query || ""
          : "";

        lastQuery = query;

        if (dwellTimer) clearTimeout(dwellTimer);
        if (query.length > 0) {
          dwellTimer = setTimeout(() => {
            dwellTimer = null;
            capture("docs_search_query", {
              query,
              result_count: lastResultCount,
            });
          }, DWELL_MS);
        }

        return response;
      });
    },
  };
}

/**
 * DocSearch transformItems option.
 * Annotates each result with its display position and tracks result count.
 */
export function searchTrackingItems(items) {
  lastResultCount = items.length;
  return items.map((item, index) => ({
    ...item,
    __searchPosition: index + 1,
  }));
}

/**
 * DocSearch navigator option.
 * Tracks result clicks before navigating.
 */
export const searchTrackingNavigator = {
  navigate({ itemUrl, item, state }) {
    resultClicked = true;
    capture("docs_search_result_clicked", {
      query: state.query,
      url: itemUrl,
      position: item.__searchPosition || null,
      result_count: lastResultCount,
    });
    window.location.assign(itemUrl);
  },
  navigateNewTab({ itemUrl, item, state }) {
    resultClicked = true;
    capture("docs_search_result_clicked", {
      query: state.query,
      url: itemUrl,
      position: item.__searchPosition || null,
      result_count: lastResultCount,
      new_tab: true,
    });
    const windowReference = window.open(itemUrl, "_blank", "noopener");
    windowReference?.focus();
  },
  navigateNewWindow({ itemUrl, item, state }) {
    resultClicked = true;
    capture("docs_search_result_clicked", {
      query: state.query,
      url: itemUrl,
      position: item.__searchPosition || null,
      result_count: lastResultCount,
      new_tab: true,
    });
    window.open(itemUrl, "_blank", "noopener");
  },
};
