import * as Turbo from "@hotwired/turbo";
import { bindToggles, preserveScroll } from "../components/nav";
import { initToc } from "../components/toc";
import { attachCopyToClipboardButton } from "../components/copyToClipboardButton";
import { themeToggle } from "../components/themeToggle";
import { initPageCopyDropdown } from "../components/pageCopyDropdown";
import docsearch from "@docsearch/js";

Turbo.start();

// Store cleanup functions for proper memory management
let cleanupFunctions = [];

document.addEventListener("turbo:render", async (event) => {
  cleanup();
  render();
});

window.addEventListener("DOMContentLoaded", () => {
  render();
});

function cleanup() {
  // Call all cleanup functions from previous renders
  cleanupFunctions.forEach((fn) => {
    if (typeof fn === "function") {
      try {
        fn();
      } catch (error) {
        console.warn("Error during cleanup:", error);
      }
    }
  });
  cleanupFunctions = [];
}

function render() {
  docsearch({
    container: "#search",
    appId: __ALGOLIA_APP_ID__,
    apiKey: __ALGOLIA_API_KEY__,
    indexName: __ALGOLIA_INDEX_NAME__,
  });

  bindToggles();
  preserveScroll();
  initToc();
  attachCopyToClipboardButton("pre.highlight");
  themeToggle();

  // Store cleanup function if component returns one
  const dropdownCleanup = initPageCopyDropdown();
  if (dropdownCleanup) {
    cleanupFunctions.push(dropdownCleanup);
  }
}

window.addEventListener("DOMContentLoaded", () => {
  document.onkeydown = (e) => {
    const event = window.event || e;

    switch (event.keyCode) {
      case 191:
        e.preventDefault();
        document.getElementById("search").focus();
        break;
    }
  };
});
