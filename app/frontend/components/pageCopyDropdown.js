// Configuration constants
const COPY_TIMEOUT = 2000;
const ERROR_TIMEOUT = 3000;
const PRODUCTION_BASE_URL = "https://buildkite.com";

// AI service configuration
const AI_SERVICES = {
  chatgpt: {
    url: "https://chat.openai.com/",
    queryParam: "q",
  },
  claude: {
    url: "https://claude.ai/new",
    queryParam: "q",
  },
  // Removed until we have have hosted MCP
  // cursor: {
  //   url: 'cursor://anysphere.cursor-deeplink/mcp/install?name=buildkite&config=eyJjb21tYW5kIjoiZG9ja2VyIHJ1biAtaSAtLXJtIC1lIEJVSUxES0lURV9BUElfVE9LRU4gZ2hjci5pby9idWlsZGtpdGUvYnVpbGRraXRlLW1jcC1zZXJ2ZXIgc3RkaW8iLCJlbnYiOnsiQlVJTERLSVRFX0FQSV9UT0tFTiI6ImJrdWFfeHh4eHh4eHgifX0%3D'
  // }
};

export function initPageCopyDropdown() {
  const dropdown = document.querySelector(".page-copy-dropdown");
  if (!dropdown) return null;

  // AbortController for cleanup
  const abortController = new AbortController();
  const { signal } = abortController;

  // Move dropdown to be inline with the first h1 heading
  positionDropdownWithHeading(dropdown);

  // Get DOM elements
  const button = dropdown.querySelector(".page-copy-dropdown__button");
  const menu = dropdown.querySelector(".page-copy-dropdown__menu");
  const copyButton = dropdown.querySelector('[data-action="copy-markdown"]');
  const viewButton = dropdown.querySelector('[data-action="view-markdown"]');
  const aiButtons = dropdown.querySelectorAll(
    '[data-action^="open-"], [data-action="connect-cursor"]'
  );

  if (!button || !menu) return null;

  // Dropdown state management
  function closeDropdown() {
    menu.classList.remove("page-copy-dropdown__menu--open");
    button.setAttribute("aria-expanded", "false");
  }

  function openDropdown() {
    menu.classList.add("page-copy-dropdown__menu--open");
    button.setAttribute("aria-expanded", "true");
  }

  function toggleDropdown() {
    const isOpen = menu.classList.contains("page-copy-dropdown__menu--open");
    if (isOpen) {
      closeDropdown();
    } else {
      openDropdown();
    }
  }

  // Event handlers
  const handleButtonClick = (e) => {
    e.preventDefault();
    e.stopPropagation();
    toggleDropdown();
  };

  const handleOutsideClick = (e) => {
    if (!dropdown.contains(e.target)) {
      closeDropdown();
    }
  };

  const handleKeyboardNavigation = (e) => {
    const isOpen = menu.classList.contains("page-copy-dropdown__menu--open");

    switch (e.key) {
      case "Escape":
        if (isOpen) {
          e.preventDefault();
          closeDropdown();
          button.focus();
        }
        break;
      case "ArrowDown":
      case "ArrowUp":
        if (isOpen) {
          e.preventDefault();
          navigateMenuItems(e.key === "ArrowDown" ? 1 : -1);
        }
        break;
    }
  };

  function navigateMenuItems(direction) {
    const focusableElements = menu.querySelectorAll("button:not(:disabled)");
    if (focusableElements.length === 0) return;

    const currentIndex = Array.from(focusableElements).findIndex(
      (el) => el === document.activeElement
    );
    let nextIndex;

    if (direction === 1) {
      // ArrowDown
      nextIndex =
        currentIndex === -1 ? 0 : (currentIndex + 1) % focusableElements.length;
    } else {
      // ArrowUp
      nextIndex =
        currentIndex === -1
          ? focusableElements.length - 1
          : (currentIndex - 1 + focusableElements.length) %
            focusableElements.length;
    }

    focusableElements[nextIndex].focus();
  }

  // Add event listeners with cleanup support
  button.addEventListener("click", handleButtonClick, { signal });
  document.addEventListener("click", handleOutsideClick, { signal });
  dropdown.addEventListener("keydown", handleKeyboardNavigation, { signal });

  // Copy to clipboard functionality
  if (copyButton) {
    copyButton.addEventListener("click", handleCopyMarkdown, { signal });
  }

  // View markdown functionality
  if (viewButton) {
    viewButton.addEventListener("click", handleViewMarkdown, { signal });
  }

  // AI integration buttons
  aiButtons.forEach((button) => {
    button.addEventListener("click", handleAIIntegration, { signal });
  });

  async function handleCopyMarkdown(e) {
    e.preventDefault();
    closeDropdown();

    const titleElement = copyButton.querySelector(
      ".page-copy-dropdown__item-title"
    );
    const icon = copyButton.querySelector(".page-copy-dropdown__item-icon svg");
    const originalTitle = titleElement?.textContent || "Copy as Markdown";

    try {
      // Show loading state
      setButtonState(copyButton, "loading", "Copying...", icon);

      const markdownContent = await fetchMarkdownContent();
      await copyToClipboard(markdownContent);

      // Show success state
      setButtonState(copyButton, "success", "Copied!", icon);

      // Reset after delay
      setTimeout(() => {
        resetButtonState(copyButton, originalTitle, icon);
      }, COPY_TIMEOUT);
    } catch (error) {
      console.error("Failed to copy markdown:", error);

      // Show error state
      setButtonState(copyButton, "error", "Failed", icon);

      setTimeout(() => {
        resetButtonState(copyButton, originalTitle, icon);
      }, ERROR_TIMEOUT);
    }
  }

  function handleViewMarkdown(e) {
    e.preventDefault();
    closeDropdown();

    const markdownUrl = buildMarkdownUrl();
    window.open(markdownUrl, "_blank");
  }

  function handleAIIntegration(e) {
    e.preventDefault();
    closeDropdown();

    const action = e.currentTarget.getAttribute("data-action");
    const targetUrl = buildAIServiceUrl(action);

    if (targetUrl) {
      window.open(targetUrl, "_blank");
    }
  }

  // Utility functions
  function setButtonState(button, state, text, icon) {
    button.classList.remove(
      "page-copy-dropdown__item--loading",
      "page-copy-dropdown__item--success",
      "page-copy-dropdown__item--error"
    );
    button.classList.add(`page-copy-dropdown__item--${state}`);

    const titleElement = button.querySelector(
      ".page-copy-dropdown__item-title"
    );
    if (titleElement) {
      titleElement.textContent = text;
    }

    if (icon) {
      if (state === "loading") {
        icon.classList.add("animate-spin");
      } else {
        icon.classList.remove("animate-spin");
      }
    }

    button.disabled = state === "loading";
  }

  function resetButtonState(button, originalTitle, icon) {
    button.classList.remove(
      "page-copy-dropdown__item--loading",
      "page-copy-dropdown__item--success",
      "page-copy-dropdown__item--error"
    );

    const titleElement = button.querySelector(
      ".page-copy-dropdown__item-title"
    );
    if (titleElement) {
      titleElement.textContent = originalTitle;
    }

    if (icon) {
      icon.classList.remove("animate-spin");
    }

    button.disabled = false;
  }

  async function fetchMarkdownContent() {
    const markdownUrl = buildMarkdownUrl();
    const response = await fetch(markdownUrl);

    if (!response.ok) {
      throw new Error(
        `Failed to fetch markdown: ${response.status} ${response.statusText}`
      );
    }

    return response.text();
  }

  async function copyToClipboard(text) {
    if (!navigator.clipboard) {
      throw new Error("Clipboard API not available");
    }

    await navigator.clipboard.writeText(text);
  }

  function buildMarkdownUrl() {
    const currentPath = window.location.pathname;
    return currentPath.endsWith("/")
      ? currentPath + "index.md"
      : currentPath + ".md";
  }

  function buildAIServiceUrl(action) {
    const markdownUrl = buildProductionMarkdownUrl();

    switch (action) {
      case "open-chatgpt":
        return buildServiceUrl(
          "chatgpt",
          `Read and analyze this Buildkite documentation page so I can ask you questions about it: ${markdownUrl}`
        );
      case "open-claude":
        return buildServiceUrl(
          "claude",
          `Read and analyze this Buildkite documentation page so I can ask you questions about it: ${markdownUrl}`
        );
      // Removed until we have have hosted MCP
      // case "connect-cursor":
      //   return AI_SERVICES.cursor.url;
      default:
        return null;
    }
  }

  function buildServiceUrl(service, prompt) {
    const config = AI_SERVICES[service];
    if (!config) return null;

    const url = new URL(config.url);
    if (config.queryParam) {
      url.searchParams.set(config.queryParam, prompt);
    }
    return url.toString();
  }

  function buildProductionMarkdownUrl() {
    const currentUrl = window.location.href;
    const productionUrl = currentUrl.replace(
      /https?:\/\/localhost:\d+/,
      PRODUCTION_BASE_URL
    );
    const cleanUrl = productionUrl.replace(/\/$/, "");
    return cleanUrl + ".md";
  }

  // Return cleanup function
  return function cleanup() {
    abortController.abort();
  };
}

/**
 * Safely positions the dropdown inline with the first h1 heading using a container wrapper
 * instead of dangerous DOM manipulation
 */
function positionDropdownWithHeading(dropdown) {
  const article = dropdown.closest(".Article");
  if (!article) return;

  const firstH1 = article.querySelector("h1");
  if (!firstH1) return;

  // Create a container wrapper to hold both h1 and dropdown
  const container = document.createElement("div");
  container.className = "page-heading-container";

  // Insert container before the h1
  firstH1.insertAdjacentElement("beforebegin", container);

  // Move h1 into container
  container.appendChild(firstH1);

  // Move dropdown into container and mark as inline
  dropdown.classList.add("page-copy-dropdown--inline");
  container.appendChild(dropdown);
}
