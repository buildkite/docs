import assert from "node:assert/strict";
import { test } from "node:test";
import { JSDOM } from "jsdom";
import { initAnimations } from "../../app/frontend/components/animations.js";

test("animations respect reduced motion and remain controllable across page visits", (t) => {
  const dom = new JSDOM(`
    <figure>
      <video data-autoplay controls></video>
      <div data-animation-controls hidden><button data-animation-toggle></button></div>
    </figure>
  `);
  const { window } = dom;
  const { document } = window;
  const previous = {
    window: globalThis.window,
    document: globalThis.document,
    AbortController: globalThis.AbortController,
  };
  Object.assign(globalThis, {
    window,
    document,
    AbortController: window.AbortController,
  });
  t.after(() => {
    Object.assign(globalThis, previous);
    window.close();
  });

  const preference = new window.EventTarget();
  preference.matches = true;
  window.matchMedia = () => preference;
  const video = document.querySelector("video");
  const button = document.querySelector("button");
  // JSDOM has no media player. Model its state/events, then exercise the UI.
  let paused = true;
  Object.defineProperty(video, "paused", { get: () => paused });
  video.play = async () => {
    paused = false;
    video.dispatchEvent(new window.Event("play"));
  };
  video.pause = () => {
    paused = true;
    video.dispatchEvent(new window.Event("pause"));
  };

  let cleanup = initAnimations();
  assert.equal(video.paused, true, "reduced motion must not autoplay");
  assert.equal(
    document.querySelector("[data-animation-controls]").hidden,
    false,
  );
  assert.equal(
    video.controls,
    false,
    "native controls must not cover the artwork",
  );
  assert.equal(button.textContent, "Play animation");
  button.click();
  assert.equal(video.paused, false, "readers can opt into playback");
  assert.equal(button.textContent, "Pause animation");
  button.click();
  assert.equal(video.paused, true);

  preference.matches = false;
  preference.dispatchEvent(new window.Event("change"));
  assert.equal(video.paused, false, "normal motion enables autoplay");
  preference.matches = true;
  preference.dispatchEvent(new window.Event("change"));
  assert.equal(video.paused, true, "a preference change stops playback");

  cleanup();
  preference.matches = false;
  preference.dispatchEvent(new window.Event("change"));
  assert.equal(
    video.paused,
    true,
    "leaving the page removes preference listeners",
  );
  cleanup = initAnimations();
  assert.equal(video.paused, false);
  button.click();
  assert.equal(
    video.paused,
    true,
    "returning must not attach duplicate button handlers",
  );
  assert.equal(button.textContent, "Play animation");
  cleanup();
});
