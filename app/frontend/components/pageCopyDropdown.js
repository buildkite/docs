const COPY_TIMEOUT = 2000;

export function initPageCopyDropdown() {
  const dropdown = document.querySelector('.page-copy-dropdown');
  if (!dropdown) return;

  const button = dropdown.querySelector('.page-copy-dropdown__button');
  const menu = dropdown.querySelector('.page-copy-dropdown__menu');
  const copyButton = dropdown.querySelector('[data-action="copy-markdown"]');
  const viewButton = dropdown.querySelector('[data-action="view-markdown"]');
  const chatgptButton = dropdown.querySelector('[data-action="open-chatgpt"]');
  const claudeButton = dropdown.querySelector('[data-action="open-claude"]');
  const cursorButton = dropdown.querySelector('[data-action="connect-cursor"]');

  // Toggle dropdown
  button.addEventListener('click', (e) => {
    e.preventDefault();
    e.stopPropagation();
    const isOpen = menu.classList.contains('page-copy-dropdown__menu--open');
    menu.classList.toggle('page-copy-dropdown__menu--open');
    button.setAttribute('aria-expanded', (!isOpen).toString());
  });

  // Close dropdown when clicking outside
  document.addEventListener('click', (e) => {
    if (!dropdown.contains(e.target)) {
      menu.classList.remove('page-copy-dropdown__menu--open');
      button.setAttribute('aria-expanded', 'false');
    }
  });

  // Handle keyboard navigation
  dropdown.addEventListener('keydown', (e) => {
    const isOpen = menu.classList.contains('page-copy-dropdown__menu--open');
    
    switch (e.key) {
      case 'Escape':
        if (isOpen) {
          e.preventDefault();
          menu.classList.remove('page-copy-dropdown__menu--open');
          button.setAttribute('aria-expanded', 'false');
          button.focus();
        }
        break;
      case 'ArrowDown':
      case 'ArrowUp':
        if (isOpen) {
          e.preventDefault();
          const focusableElements = menu.querySelectorAll('button');
          const currentIndex = Array.from(focusableElements).findIndex(el => el === document.activeElement);
          let nextIndex;
          
          if (e.key === 'ArrowDown') {
            nextIndex = currentIndex === -1 ? 0 : (currentIndex + 1) % focusableElements.length;
          } else {
            nextIndex = currentIndex <= 0 ? focusableElements.length - 1 : currentIndex - 1;
          }
          
          focusableElements[nextIndex].focus();
        } else if (e.key === 'ArrowDown') {
          e.preventDefault();
          menu.classList.add('page-copy-dropdown__menu--open');
          button.setAttribute('aria-expanded', 'true');
          copyButton.focus();
        }
        break;
    }
  });

  // Handle copy to clipboard
  copyButton.addEventListener('click', async (e) => {
    e.preventDefault();
    menu.classList.remove('page-copy-dropdown__menu--open');
    
    const titleElement = copyButton.querySelector('.page-copy-dropdown__item-title');
    const icon = copyButton.querySelector('.page-copy-dropdown__item-icon svg');
    const originalTitle = titleElement?.textContent || 'Copy as Markdown';
    
    try {
      // Show loading state
      copyButton.classList.add('page-copy-dropdown__item--loading');
      if (titleElement) {
        titleElement.textContent = 'Copying...';
      }
      if (icon) {
        icon.classList.add('animate-spin');
      }
      copyButton.disabled = true;
      
      // Fetch the markdown content from the .md URL
      const currentUrl = window.location.pathname;
      const markdownUrl = currentUrl + '.md';
      
      const response = await fetch(markdownUrl);
      if (!response.ok) {
        throw new Error(`Failed to fetch markdown: ${response.status} ${response.statusText}`);
      }
      
      const markdownContent = await response.text();
      
      // Check if clipboard API is available
      if (!navigator.clipboard) {
        throw new Error('Clipboard API not available');
      }
      
      await navigator.clipboard.writeText(markdownContent);
      
      // Show success state
      copyButton.classList.remove('page-copy-dropdown__item--loading');
      copyButton.classList.add('page-copy-dropdown__item--success');
      if (titleElement) {
        titleElement.textContent = 'Copied!';
      }
      if (icon) {
        icon.classList.remove('animate-spin');
      }
      
      // Reset after delay
      setTimeout(() => {
        copyButton.classList.remove('page-copy-dropdown__item--success');
        if (titleElement) {
          titleElement.textContent = originalTitle;
        }
        copyButton.disabled = false;
      }, COPY_TIMEOUT);
      
    } catch (error) {
      console.error('Failed to copy markdown:', error);
      
      // Show error state
      copyButton.classList.remove('page-copy-dropdown__item--loading');
      copyButton.classList.add('page-copy-dropdown__item--error');
      if (titleElement) {
        titleElement.textContent = 'Failed';
      }
      if (icon) {
        icon.classList.remove('animate-spin');
      }
      
      setTimeout(() => {
        copyButton.classList.remove('page-copy-dropdown__item--error');
        if (titleElement) {
          titleElement.textContent = originalTitle;
        }
        copyButton.disabled = false;
      }, 3000);
    }
  });

  // Handle view as markdown
  viewButton.addEventListener('click', (e) => {
    e.preventDefault();
    menu.classList.remove('page-copy-dropdown__menu--open');
    
    const currentUrl = window.location.pathname;
    const markdownUrl = currentUrl + '.md';
    window.open(markdownUrl, '_blank');
  });

  // Helper function to get public documentation URL
  function getPublicDocURL() {
    // Convert local/dev URLs to production buildkite.com URLs
    const currentPath = window.location.pathname;
    return `https://buildkite.com${currentPath}.md`;
  }

  // Helper function to get page title
  function getPageTitle() {
    return document.title || 'Buildkite Documentation';
  }

  // Handle ChatGPT integration
  if (chatgptButton) {
    chatgptButton.addEventListener('click', (e) => {
      e.preventDefault();
      menu.classList.remove('page-copy-dropdown__menu--open');
      
      const publicURL = getPublicDocURL();
      const prompt = `Read and analyze this Buildkite documentation page so I can ask you questions about it: ${publicURL}`;
      
      // ChatGPT URL with pre-filled message
      const chatGPTURL = `https://chat.openai.com/?q=${encodeURIComponent(prompt)}`;
      window.open(chatGPTURL, '_blank');
    });
  }

  // Handle Claude integration
  if (claudeButton) {
    claudeButton.addEventListener('click', (e) => {
      e.preventDefault();
      menu.classList.remove('page-copy-dropdown__menu--open');
      
      const publicURL = getPublicDocURL();
      const prompt = `Read and analyze this Buildkite documentation page so I can ask you questions about it: ${publicURL}`;
      
      // Claude URL with pre-filled message
      const claudeURL = `https://claude.ai/chat?q=${encodeURIComponent(prompt)}`;
      window.open(claudeURL, '_blank');
    });
  }

  // Handle Cursor MCP integration
  if (cursorButton) {
    cursorButton.addEventListener('click', (e) => {
      e.preventDefault();
      menu.classList.remove('page-copy-dropdown__menu--open');
      
      // Cursor MCP URL with title and URL parameters
      const cursorURL = 'cursor://anysphere.cursor-deeplink/mcp/install?name=Helius%20Docs&config=eyJuYW1lIjoiSGVsaXVzIERvY3MiLCJ1cmwiOiJodHRwczovL3d3dy5oZWxpdXMuZGV2L2RvY3MvbWNwIn0%3D';
      window.open(cursorURL, '_blank');
    });
  }
}
