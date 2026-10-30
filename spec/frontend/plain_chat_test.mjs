import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import { runInNewContext } from "node:vm";

for (const earlyOpen of [false, true]) {
  test(`syncs changed page context only while chat is open (early open: ${earlyOpen})`, async () => {
    const document = new EventTarget();
    const window = new EventTarget();
    window.location = new URL(
      "https://example.com/docs/agent?query=ignored#hooks",
    );
    let loader, options, onOpen, onClose, finishInit;
    const updates = [];
    document.createElement = () => ({});
    document.getElementsByTagName = () => [
      { appendChild: (el) => (loader = el) },
    ];
    const Plain = {
      init: (config) => {
        options = config;
        return new Promise((resolve) => (finishInit = resolve));
      },
      update: (config) => {
        updates.push(config);
        options = { ...options, ...config };
      },
      onOpen: (callback) => (onOpen = callback),
      onClose: (callback) => (onClose = callback),
    };
    const source = readFileSync(
      new URL(
        "../../app/views/application/_plain_chat.html.erb",
        import.meta.url,
      ),
      "utf8",
    );
    // The ERB values supply only the app ID and logo URL inside the script.
    runInNewContext(source.replace(/<%[\s\S]*?%>/g, ""), {
      document,
      window,
      Plain,
      localStorage: { getItem: () => "dark" },
    });
    loader.onload();

    const initialTier = options.threadDetails.tierIdentifier.tierId;
    const pageUrl = () => options.threadDetails.threadFields[0].stringValue;
    assert.equal(pageUrl(), "https://example.com/docs/agent#hooks");
    assert.equal(
      updates.length,
      0,
      "initialization must not repeat the update",
    );

    if (earlyOpen) {
      // The SDK does not replay open events registered after this click.
      onOpen?.();
      window.location.hash = "configuration";
      document.dispatchEvent(new Event("turbo:load"));
      assert.equal(updates.length, 0, "updates must wait for initialization");
    }
    finishInit();
    await Promise.resolve();
    if (!earlyOpen) {
      onOpen();
      assert.equal(
        updates.length,
        0,
        "opening on the same page needs no update",
      );
      window.location.hash = "configuration";
      document.dispatchEvent(new Event("turbo:load"));
    }
    assert.equal(updates.length, 1);
    assert.equal(pageUrl(), "https://example.com/docs/agent#configuration");
    onClose();
    for (const page of ["pipelines", "apis", "platform"]) {
      window.location = new URL(
        `https://example.com/docs/${page}?query=ignored`,
      );
      document.dispatchEvent(new Event("turbo:load"));
    }
    window.location.hash = "security";
    window.dispatchEvent(new Event("hashchange"));
    assert.equal(
      updates.length,
      1,
      "closed chat must not update while browsing",
    );

    onOpen();
    assert.equal(updates.length, 2);
    assert.equal(pageUrl(), "https://example.com/docs/platform#security");
    document.dispatchEvent(new Event("turbo:load"));
    window.location.search = "?different=query";
    window.dispatchEvent(new Event("hashchange"));
    assert.equal(updates.length, 2, "unchanged sanitized URLs need no update");

    window.location = new URL("https://example.com/docs/agent#configuration");
    document.dispatchEvent(new Event("turbo:load"));
    assert.equal(pageUrl(), "https://example.com/docs/agent#configuration");
    window.location.hash = "hooks";
    window.dispatchEvent(new Event("hashchange"));
    assert.equal(pageUrl(), "https://example.com/docs/agent#hooks");
    assert.equal(updates.length, 4);
    assert.equal(options.threadDetails.tierIdentifier.tierId, initialTier);
    assert.equal(
      options.threadDetails.threadFields[0].key,
      "feedbackescalation_url",
    );
    assert.equal(options.threadDetails.threadFields[0].type, "STRING");
    assert.equal(options.theme, "dark");

    onClose();
    document.dispatchEvent(new Event("turbo:load"));
    onOpen();
    assert.equal(
      updates.length,
      4,
      "reopening on the same page needs no update",
    );
  });
}
