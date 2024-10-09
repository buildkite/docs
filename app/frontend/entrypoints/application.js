import * as Turbo from "@hotwired/turbo";
import { bindToggles } from "../components/nav";
import { initToc } from "../components/toc";
import { attachCopyToClipboardButton } from "../components/copyToClipboardButton";
import { themeToggle } from "../components/themeToggle";
import docsearch from "@docsearch/js";

Turbo.start();

document.addEventListener("turbo:render", async (event) => {
  render();
});

window.addEventListener("DOMContentLoaded", () => {
  render();
});

function render() {
  docsearch({
    container: "#search",
    appId: __ALGOLIA_APP_ID__,
    apiKey: __ALGOLIA_API_KEY__,
    indexName: __ALGOLIA_INDEX_NAME__,
  });

  bindToggles();
  initToc();
  attachCopyToClipboardButton("pre.highlight");
  themeToggle();
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
