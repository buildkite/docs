import * as Turbo from "@hotwired/turbo";
import { bindToggles } from "../components/nav";

Turbo.start();

document.addEventListener("turbo:render", async (event) => {
  bindToggles();
});

window.addEventListener("DOMContentLoaded", () => {
  bindToggles();
});
