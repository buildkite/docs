// Maps the docs site's theme setting (stored under the "docs-theme" key) to
// Plain's theme option. "system" maps to "auto" since Plain's "auto" already
// follows the browser's prefers-color-scheme, same as the docs site's
// "system" option.
const PLAIN_THEME_MAP = {
  light: "light",
  dark: "dark",
  system: "auto",
};

export function syncPlainChatTheme(theme) {
  if (typeof window.Plain === "undefined") return;
  window.Plain.update({ theme: PLAIN_THEME_MAP[theme] || "auto" });
}

// Plain mounts its widget as a plain child of <body>. Turbo replaces <body>
// wholesale on every navigation, which would destroy that element and leave
// Plain.open() updating a detached node. #plain-chat-turbo-wrapper is a
// server-rendered data-turbo-permanent container (same id in every layout),
// so Turbo preserves it across navigations; moving Plain's widget into it
// the moment it appears makes the widget survive navigation along with it.
function preservePlainChatAcrossNavigations() {
  const wrapper = document.getElementById("plain-chat-turbo-wrapper");
  if (!wrapper) return;

  const plainChat = document.getElementById("plain-chat");
  if (plainChat) {
    if (plainChat.parentElement !== wrapper) wrapper.appendChild(plainChat);
    return;
  }

  const observer = new MutationObserver(() => {
    const el = document.getElementById("plain-chat");
    if (el) {
      wrapper.appendChild(el);
      observer.disconnect();
    }
  });
  observer.observe(document.body, { childList: true });
}

export function initPlainChat() {
  preservePlainChatAcrossNavigations();

  const button = document.getElementById("plain-chat-button");
  if (!button) return;

  button.onclick = function () {
    if (typeof window.Plain === "undefined") {
      const userMessage =
        button.dataset.plainConfigured === "true"
          ? "Plain chat failed to load. Contact support@buildkite.com and let us know."
          : "Plain chat is not available. Contact support@buildkite.com and let us know.";

      console.error(userMessage);

      // DD_RUM is only loaded when DD_RUM_ENABLED is set (production), giving
      // a monitored, alertable signal there without requiring it locally.
      // This message is separate from userMessage above: DD_RUM is read by
      // Buildkite staff, not site visitors, so it carries the diagnostic
      // detail (which check failed) instead of the visitor-facing wording.
      if (typeof window.DD_RUM !== "undefined") {
        const diagnosticMessage =
          button.dataset.plainConfigured === "true"
            ? "Plain chat script failed to load even though PLAIN_CHAT_APP_ID is set."
            : "Plain chat button clicked but PLAIN_CHAT_APP_ID is not configured.";
        // DD_RUM starts as a stub exposing only q/onReady until the real SDK
        // finishes loading; calling addError directly can throw if that
        // hasn't happened yet. onReady queues the call safely either way.
        window.DD_RUM.onReady(function () {
          window.DD_RUM.addError(new Error(diagnosticMessage));
        });
      }

      return;
    }

    window.Plain.open();
  };
}
