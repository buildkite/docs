const COPY_TIMEOUT = 2000;

export function initPageCopyDropdown() {
  const dropdown = document.querySelector('.page-copy-dropdown');
  if (!dropdown) return;

  // Move dropdown to be inline with the first h1 heading
  moveDropdownInlineWithHeading(dropdown);

  const button = dropdown.querySelector('.page-copy-dropdown__button');
  const menu = dropdown.querySelector('.page-copy-dropdown__menu');
  const copyButton = dropdown.querySelector('[data-action="copy-markdown"]');
  const viewButton = dropdown.querySelector('[data-action="view-markdown"]');
  const chatgptButton = dropdown.querySelector('[data-action="open-chatgpt"]');
  const claudeButton = dropdown.querySelector('[data-action="open-claude"]');
  const cursorButton = dropdown.querySelector('[data-action="connect-cursor"]');

  if (!button || !menu) return;

  // Toggle dropdown
  button.addEventListener('click', (e) => {
    e.preventDefault();
    e.stopPropagation();
    const isOpen = menu.classList.contains('page-copy-dropdown__menu--open');
    menu.classList.toggle('page-copy-dropdown__menu--open');
    button.setAttribute('aria-expanded', (!isOpen).toString());
  });

  // Close dropdown when clicking outside
  document.addEventListener('click', function(e) {
    if (!dropdown.contains(e.target)) {
      closeDropdown();
    }
  });

  // Handle keyboard navigation
  dropdown.addEventListener('keydown', function(e) {
    const isOpen = menu.classList.contains('page-copy-dropdown__menu--open');
    
    switch (e.key) {
      case 'Escape':
        if (isOpen) {
          e.preventDefault();
          closeDropdown();
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
            nextIndex = currentIndex === -1 ? focusableElements.length - 1 : (currentIndex - 1 + focusableElements.length) % focusableElements.length;
          }
          
          focusableElements[nextIndex].focus();
        }
        break;
    }
  });

  function closeDropdown() {
    menu.classList.remove('page-copy-dropdown__menu--open');
    button.setAttribute('aria-expanded', 'false');
  }

  /**
   * Moves the dropdown to be inline with the first h1 heading
   */
  function moveDropdownInlineWithHeading(dropdown) {
    const article = dropdown.closest('.Article');
    if (!article) return;

    // Find the first h1 in the article content (after the dropdown)
    const firstH1 = article.querySelector('h1');
    if (!firstH1) return;

    // Clone the h1 content
    const headingText = firstH1.innerHTML;
    
    // Clear the h1 and make it a flex container
    firstH1.innerHTML = '';
    firstH1.style.display = 'flex';
    firstH1.style.alignItems = 'center';
    firstH1.style.flexWrap = 'wrap';
    firstH1.style.gap = '1rem';
    firstH1.style.marginTop = '0';
    firstH1.style.marginBottom = '1.5rem';
    firstH1.style.lineHeight = '1.3';
    
    // Create a span for the heading text
    const headingSpan = document.createElement('span');
    headingSpan.innerHTML = headingText;
    headingSpan.style.flex = '1';
    headingSpan.style.minWidth = 'fit-content';
    
    // Move the dropdown into the h1
    dropdown.remove();
    dropdown.classList.add('page-copy-dropdown--inline');
    
    // Add elements to h1: heading text first, then dropdown
    firstH1.appendChild(headingSpan);
    firstH1.appendChild(dropdown);
    
    console.log('Dropdown moved inline with heading');
  }

  // Handle copy to clipboard
  if (copyButton) {
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
  }

  // Handle view as markdown
  if (viewButton) {
    viewButton.addEventListener('click', (e) => {
      e.preventDefault();
      menu.classList.remove('page-copy-dropdown__menu--open');
      
      const currentUrl = window.location.pathname;
      const markdownUrl = currentUrl + '.md';
      window.open(markdownUrl, '_blank');
    });
  }

  // Handle AI integration buttons
  [chatgptButton, claudeButton, cursorButton].forEach(button => {
    if (button) {
      button.addEventListener('click', (e) => {
        e.preventDefault();
        menu.classList.remove('page-copy-dropdown__menu--open');
        
        const action = button.getAttribute('data-action');
        const pageTitle = document.querySelector('h1')?.textContent || document.title;
        const pageUrl = window.location.href;
        
        // Convert local URLs to production URLs for AI services
        const productionUrl = pageUrl.replace(/https?:\/\/localhost:\d+/, 'https://buildkite.com');
        const markdownUrl = productionUrl.replace(/\/$/, '') + '.md';
        
        let targetUrl;
        
        switch (action) {
          case 'open-chatgpt':
            const chatgptPrompt = `Read and analyze this Buildkite documentation page so I can ask you questions about it: ${markdownUrl}`;
            targetUrl = `https://chat.openai.com/?q=${encodeURIComponent(chatgptPrompt)}`;
            break;
          case 'open-claude':
            const claudePrompt = `Read and analyze this Buildkite documentation page so I can ask you questions about it: ${markdownUrl}`;
            targetUrl = `https://claude.ai/new?q=${encodeURIComponent(claudePrompt)}`;
            break;
          case 'connect-cursor':
            targetUrl = 'cursor://anysphere.cursor-deeplink/mcp/install?name=buildkite&config=eyJjb21tYW5kIjoiZG9ja2VyIHJ1biAtaSAtLXJtIC1lIEJVSUxES0lURV9BUElfVE9LRU4gZ2hjci5pby9idWlsZGtpdGUvYnVpbGRraXRlLW1jcC1zZXJ2ZXIgc3RkaW8iLCJlbnYiOnsiQlVJTERLSVRFX0FQSV9UT0tFTiI6ImJrdWFfeHh4eHh4eHgifX0%3D';
            break;
        }
        
        if (targetUrl) {
          window.open(targetUrl, '_blank');
        }
      });
    }
  });
}
