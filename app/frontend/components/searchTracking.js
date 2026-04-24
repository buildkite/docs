/**
 * PostHog tracking for DocSearch interactions.
 *
 * Events:
 * - docs_search_query: User searched (fires after 1s dwell)
 * - docs_search_result_clicked: User clicked a search result
 *
 * Both events share a search_session_id to link queries and clicks.
 */

const DWELL_MS = 1000;

let lastQuery = "";
let lastResultCount = 0;
let dwellTimer = null;
let globalPosition = 0;
let searchSessionId = null;

function generateSessionId() {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 7);
}

function capture(event, properties) {
  if (typeof posthog !== "undefined") {
    posthog.capture(event, {
      ...properties,
      search_session_id: searchSessionId,
      page_url: window.location.href,
      page_path: window.location.pathname,
    });
  }
}

/**
 * Handles click events on DocSearch result links.
 * Delegated from the document to catch clicks inside the modal.
 */
function onResultClick(event) {
  const hit = event.target.closest(".DocSearch-Hit");
  if (!hit) return;

  const link = hit.querySelector("a[href]");
  if (!link) return;

  const allHits = Array.from(document.querySelectorAll(".DocSearch-Hit"));
  const position = allHits.indexOf(hit) + 1;
  const title = hit.querySelector(".DocSearch-Hit-title")?.textContent?.trim();

  capture("docs_search_result_clicked", {
    query: lastQuery,
    option_clicked: title || link.href,
    url: link.href,
    position: position || null,
    result_count: lastResultCount,
  });
}

/**
 * Observes body class changes to detect DocSearch modal open/close.
 * Starts a new search session when the modal opens.
 * Returns a cleanup function to disconnect the observer.
 */
export function initSearchTracking() {
  const observer = new MutationObserver(() => {
    const isOpen = document.body.classList.contains("DocSearch--active");
    if (isOpen && !searchSessionId) {
      searchSessionId = generateSessionId();
      lastQuery = "";
      lastResultCount = 0;
    } else if (!isOpen && searchSessionId) {
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
      searchSessionId = null;
    }
  });

  observer.observe(document.body, {
    attributes: true,
    attributeFilter: ["class"],
  });

  document.addEventListener("click", onResultClick, true);

  return () => {
    if (dwellTimer) {
      clearTimeout(dwellTimer);
      dwellTimer = null;
    }
    observer.disconnect();
    document.removeEventListener("click", onResultClick, true);
  };
}

/**
 * DocSearch transformSearchClient option.
 * Wraps the Algolia search client to sort hits by content type priority
 * (docs > plugins > blog > changelog) before DocSearch groups them into
 * sections, and to capture queries with dwell-based debounce.
 */
export function searchTrackingClient(searchClient) {
  return {
    ...searchClient,
    search(queries) {
      return searchClient.search(queries).then((response) => {
        response.results?.forEach((result) => {
          result.hits?.sort((a, b) => sectionPriority(a) - sectionPriority(b));
        });

        const query = Array.isArray(queries)
          ? queries[0]?.query || queries[0]?.params?.query || ""
          : "";

        lastQuery = query;
        lastResultCount = 0;
        globalPosition = 0;

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

// hierarchy.lvl0 is the section label set by DocSearch selectors.
// Unlisted doc sections (e.g. "Test Engine", "Package Registries") fall
// through to the default of 3, sitting between APIs and Plugins.
const SECTION_PRIORITY = {
  Pipelines: 0,
  Platform: 1,
  "Test Engine": 2,
  "Package Registries": 3,
  APIs: 4,
  Plugins: 5,
  Blog: 6,
  Changelog: 7,
};

function sectionPriority(item) {
  return SECTION_PRIORITY[item.hierarchy?.lvl0] ?? 5;
}

/**
 * DocSearch transformItems option.
 * Annotates each result with its display position and tracks result count.
 */
export function searchTrackingItems(items) {
  lastResultCount += items.length;
  return items.map((item) => {
    globalPosition += 1;
    return {
      ...item,
      __searchPosition: globalPosition,
    };
  });
}

/**
 * DocSearch navigator option.
 * Tracks result clicks via keyboard navigation (Enter key).
 */
export const searchTrackingNavigator = {
  navigate({ itemUrl, item, state }) {
    capture("docs_search_result_clicked", {
      query: state.query,
      option_clicked: item.hierarchy?.lvl1 || itemUrl,
      url: itemUrl,
      position: item.__searchPosition || null,
      result_count: lastResultCount,
    });
    window.location.assign(itemUrl);
  },
  navigateNewTab({ itemUrl, item, state }) {
    capture("docs_search_result_clicked", {
      query: state.query,
      option_clicked: item.hierarchy?.lvl1 || itemUrl,
      url: itemUrl,
      position: item.__searchPosition || null,
      result_count: lastResultCount,
      new_tab: true,
    });
    const windowReference = window.open(itemUrl, "_blank", "noopener");
    windowReference?.focus();
  },
  navigateNewWindow({ itemUrl, item, state }) {
    capture("docs_search_result_clicked", {
      query: state.query,
      option_clicked: item.hierarchy?.lvl1 || itemUrl,
      url: itemUrl,
      position: item.__searchPosition || null,
      result_count: lastResultCount,
      new_tab: true,
    });
    window.open(itemUrl, "_blank", "noopener");
  },
};
