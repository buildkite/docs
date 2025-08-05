const clipboardDocumentIcon = `
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M8.25 7.5V6.10822C8.25 4.97324 9.09499 4.01015 10.2261 3.91627C10.5994 3.88529 10.9739 3.85858 11.3495 3.83619M15.75 18H18C19.2426 18 20.25 16.9926 20.25 15.75V6.10822C20.25 4.97324 19.405 4.01015 18.2739 3.91627C17.9006 3.88529 17.5261 3.85858 17.1505 3.83619M15.75 18.75V16.875C15.75 15.011 14.239 13.5 12.375 13.5H10.875C10.2537 13.5 9.75 12.9963 9.75 12.375V10.875C9.75 9.01104 8.23896 7.5 6.375 7.5H5.25M17.1505 3.83619C16.8672 2.91757 16.0116 2.25 15 2.25H13.5C12.4884 2.25 11.6328 2.91757 11.3495 3.83619M17.1505 3.83619C17.2152 4.04602 17.25 4.26894 17.25 4.5V5.25H11.25V4.5C11.25 4.26894 11.2848 4.04602 11.3495 3.83619M6.75 7.5H4.875C4.25368 7.5 3.75 8.00368 3.75 8.625V20.625C3.75 21.2463 4.25368 21.75 4.875 21.75H14.625C15.2463 21.75 15.75 21.2463 15.75 20.625V16.5C15.75 11.5294 11.7206 7.5 6.75 7.5Z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
`;

const chevronDownIcon = `
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M19.5 8.25L12 15.75L4.5 8.25" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
`;

const externalLinkIcon = `
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M13.5 6H5.25A2.25 2.25 0 0 0 3 8.25v10.5A2.25 2.25 0 0 0 5.25 21h10.5A2.25 2.25 0 0 0 18 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
`;

const checkedCircleIcon = `
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M9 12.75L11.25 15L15 9.75M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
`;

const spinnerIcon = `
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" class="animate-spin">
    <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2" stroke-dasharray="31.416" stroke-dashoffset="31.416" opacity="0.3"/>
    <path d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" fill="currentColor"/>
  </svg>
`;

const chatGPTIcon = `
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M22.2819 9.8211a5.9847 5.9847 0 0 0-.5157-4.9108 6.0462 6.0462 0 0 0-6.5098-2.9A6.0651 6.0651 0 0 0 4.9807 4.1818a5.9847 5.9847 0 0 0-3.9977 2.9 6.0462 6.0462 0 0 0 .7427 7.0966 5.98 5.98 0 0 0 .511 4.9107 6.051 6.051 0 0 0 6.5146 2.9001A5.9847 5.9847 0 0 0 13.2599 24a6.0557 6.0557 0 0 0 5.7718-4.2058 5.9894 5.9894 0 0 0 3.9977-2.9001 6.0557 6.0557 0 0 0-.7475-7.0729zm-9.022 12.6081a4.4755 4.4755 0 0 1-2.8764-1.0408l.1419-.0804 4.7783-2.7582a.7948.7948 0 0 0 .3927-.6813v-6.7369l2.02 1.1686a.071.071 0 0 1 .038.052v5.5826a4.504 4.504 0 0 1-4.4945 4.4944zm-9.6607-4.1254a4.4708 4.4708 0 0 1-.5346-3.0137l.142.0852 4.783 2.7582a.7712.7712 0 0 0 .7806 0l5.8428-3.3685v2.3324a.0804.0804 0 0 1-.0332.0615L9.74 19.9502a4.4992 4.4992 0 0 1-6.1408-1.6464zM2.3408 7.8956a4.485 4.485 0 0 1 2.3655-1.9728V11.6a.7664.7664 0 0 0 .3879.6765l5.8144 3.3543-2.0201 1.1685a.0757.0757 0 0 1-.071 0l-4.8303-2.7865A4.504 4.504 0 0 1 2.3408 7.872zm16.5963 3.8558L13.1038 8.364 15.1192 7.2a.0757.0757 0 0 1 .071 0l4.8303 2.7913a4.4944 4.4944 0 0 1-.6765 8.1042v-5.6772a.79.79 0 0 0-.407-.667zm2.0107-3.0231l-.142-.0852-4.7735-2.7818a.7759.7759 0 0 0-.7854 0L9.409 9.2297V6.8974a.0662.0662 0 0 1 .0284-.0615l4.8303-2.7866a4.4992 4.4992 0 0 1 6.6802 4.66zM8.3065 12.863l-2.02-1.1638a.0804.0804 0 0 1-.038-.0567V6.0742a4.4992 4.4992 0 0 1 7.3757-3.4537l-.142.0805L8.704 5.459a.7948.7948 0 0 0-.3927.6813zm1.0976-2.3654l2.602-1.4998 2.6069 1.4998v2.9994l-2.5974 1.4997-2.6067-1.4997Z" fill="currentColor"/>
  </svg>
`;

const claudeIcon = `
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M7.307 3.043L4.54 17.235c-.211.891.386 1.796 1.333 2.02.947.224 1.924-.27 2.183-1.104L11.154 7.85c.26-.834 1.236-1.328 2.183-1.104.947.224 1.544 1.129 1.333 2.02L11.903 22.957c-.188.891.423 1.796 1.365 2.02s1.909-.27 2.165-1.104L18.2 9.681c.256-.834 1.227-1.328 2.169-1.104.942.224 1.553 1.129 1.365 2.02L18.967 24.789c-.188.891.423 1.796 1.365 2.02.942.224 1.909-.27 2.165-1.104l2.767-14.192c.256-.834-.423-1.796-1.365-2.02-.942-.224-1.909.27-2.165 1.104L18.967.405c-.256.834-1.223 1.328-2.165 1.104-.942-.224-1.553-1.129-1.365-2.02L18.2 -14.703c.188-.891-.423-1.796-1.365-2.02-.942-.224-1.909.27-2.165 1.104L11.903-1.427c-.256.834-1.218 1.328-2.165 1.104-.947-.224-1.553-1.129-1.365-2.02L11.14-16.535c.188-.891-.386-1.796-1.333-2.02-.947-.224-1.924.27-2.183 1.104L4.757-7.15c-.259.834-1.236 1.328-2.183 1.104C1.627-6.27 1.03-7.175 1.241-8.066L4.008-22.258c.211-.891-.386-1.796-1.333-2.02-.947-.224-1.924.27-2.183 1.104L-2.275-8.982c-.259.834.386 1.796 1.333 2.02.947.224 1.924-.27 2.183-1.104L4.008 3.226c.259-.834 1.236-1.328 2.183-1.104.947.224 1.544 1.129 1.333 2.02z" fill="currentColor"/>
    <circle cx="12" cy="12" r="3" fill="currentColor"/>
  </svg>
`;

const cursorIcon = `
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M5.5 3.21a.909.909 0 0 0-1.09.726L3.5 6.5l2.572.429c.228.038.395.24.395.475v1.618c0 .3-.156.578-.416.731l-2.551 1.506v5.963c0 .41.272.769.67.877.398.108.82-.106.997-.506l7.896-17.851A.909.909 0 0 0 11.25 2.5L5.5 3.21zM18.5 20.79a.909.909 0 0 0 1.09-.726L20.5 17.5l-2.572-.429a.573.573 0 0 1-.395-.475v-1.618c0-.3.156-.578.416-.731l2.551-1.506V7.278c0-.41-.272-.769-.67-.877-.398-.108-.82.106-.997.506L11.937 24.258a.909.909 0 0 0 .813 1.242L18.5 20.79V20.79z" fill="currentColor"/>
  </svg>
`;

const COPY_TIMEOUT = 2000;

export function initPageCopyDropdown() {
  const container = document.querySelector('.PageCopyDropdown');
  if (!container) return;

  const button = container.querySelector('.PageCopyDropdown__button');
  const dropdown = container.querySelector('.PageCopyDropdown__menu');
  const copyButton = container.querySelector('.PageCopyDropdown__copy');
  const viewButton = container.querySelector('.PageCopyDropdown__view');
  const chatGPTButton = container.querySelector('.PageCopyDropdown__chatgpt');
  const claudeButton = container.querySelector('.PageCopyDropdown__claude');
  const cursorButton = container.querySelector('.PageCopyDropdown__cursor');

  // Toggle dropdown
  button.addEventListener('click', (e) => {
    e.preventDefault();
    e.stopPropagation();
    const isOpen = dropdown.classList.contains('PageCopyDropdown__menu--open');
    dropdown.classList.toggle('PageCopyDropdown__menu--open');
    button.setAttribute('aria-expanded', (!isOpen).toString());
  });

  // Close dropdown when clicking outside
  document.addEventListener('click', (e) => {
    if (!container.contains(e.target)) {
      dropdown.classList.remove('PageCopyDropdown__menu--open');
      button.setAttribute('aria-expanded', 'false');
    }
  });

  // Handle keyboard navigation
  container.addEventListener('keydown', (e) => {
    const isOpen = dropdown.classList.contains('PageCopyDropdown__menu--open');
    
    switch (e.key) {
      case 'Escape':
        if (isOpen) {
          e.preventDefault();
          dropdown.classList.remove('PageCopyDropdown__menu--open');
          button.setAttribute('aria-expanded', 'false');
          button.focus();
        }
        break;
      case 'ArrowDown':
      case 'ArrowUp':
        if (isOpen) {
          e.preventDefault();
          const focusableElements = dropdown.querySelectorAll('button');
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
          dropdown.classList.add('PageCopyDropdown__menu--open');
          button.setAttribute('aria-expanded', 'true');
          copyButton.focus();
        }
        break;
    }
  });

  // Handle copy to clipboard
  copyButton.addEventListener('click', async (e) => {
    e.preventDefault();
    dropdown.classList.remove('PageCopyDropdown__menu--open');
    
    // Store original content
    const originalContent = copyButton.innerHTML;
    
    try {
      // Show loading state
      copyButton.innerHTML = `${spinnerIcon} Copying...`;
      copyButton.classList.add('PageCopyDropdown__copy--loading');
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
      copyButton.innerHTML = `${checkedCircleIcon} Copied!`;
      copyButton.classList.remove('PageCopyDropdown__copy--loading');
      copyButton.classList.add('PageCopyDropdown__copy--success');
      
      setTimeout(() => {
        copyButton.innerHTML = originalContent;
        copyButton.classList.remove('PageCopyDropdown__copy--success');
        copyButton.disabled = false;
      }, COPY_TIMEOUT);
      
    } catch (error) {
      console.error('Failed to copy markdown:', error);
      
      // Show error state
      const errorMessage = error.message.includes('Clipboard API') 
        ? 'Clipboard not supported'
        : 'Copy failed';
      
      copyButton.innerHTML = `${clipboardDocumentIcon} ${errorMessage}`;
      copyButton.classList.remove('PageCopyDropdown__copy--loading');
      copyButton.classList.add('PageCopyDropdown__copy--error');
      
      setTimeout(() => {
        copyButton.innerHTML = originalContent;
        copyButton.classList.remove('PageCopyDropdown__copy--error');
        copyButton.disabled = false;
      }, COPY_TIMEOUT);
    }
  });

  // Handle view as markdown
  viewButton.addEventListener('click', (e) => {
    e.preventDefault();
    dropdown.classList.remove('PageCopyDropdown__menu--open');
    
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
  if (chatGPTButton) {
    chatGPTButton.addEventListener('click', (e) => {
      e.preventDefault();
      dropdown.classList.remove('PageCopyDropdown__menu--open');
      
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
      dropdown.classList.remove('PageCopyDropdown__menu--open');
      
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
      dropdown.classList.remove('PageCopyDropdown__menu--open');
      
      // Cursor MCP URL with title and URL parameters
      const cursorURL = 'cursor://anysphere.cursor-deeplink/mcp/install?name=Helius%20Docs&config=eyJuYW1lIjoiSGVsaXVzIERvY3MiLCJ1cmwiOiJodHRwczovL3d3dy5oZWxpdXMuZGV2L2RvY3MvbWNwIn0%3D';
      window.open(cursorURL, '_blank');
    });
  }
}
