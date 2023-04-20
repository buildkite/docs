import * as Turbo from "@hotwired/turbo";
import { bindToggles } from "../components/nav";
import { initToc } from "../components/toc";
import { attachCopyToClipboardButton } from "../components/copyToClipboardButton";

Turbo.start();

document.addEventListener("turbo:render", async (event) => {
  render();
});

window.addEventListener("DOMContentLoaded", () => {
  render();
});

function render() {
  bindToggles();
  initToc();
  attachCopyToClipboardButton("pre.highlight");
}
