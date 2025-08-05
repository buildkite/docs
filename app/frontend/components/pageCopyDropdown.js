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

const COPY_TIMEOUT = 2000;

export function initPageCopyDropdown() {
  const container = document.querySelector('.PageCopyDropdown');
  if (!container) return;

  const button = container.querySelector('.PageCopyDropdown__button');
  const dropdown = container.querySelector('.PageCopyDropdown__menu');
  const copyButton = container.querySelector('.PageCopyDropdown__copy');
  const viewButton = container.querySelector('.PageCopyDropdown__view');

  // Toggle dropdown
  button.addEventListener('click', (e) => {
    e.preventDefault();
    e.stopPropagation();
    dropdown.classList.toggle('PageCopyDropdown__menu--open');
  });

  // Close dropdown when clicking outside
  document.addEventListener('click', (e) => {
    if (!container.contains(e.target)) {
      dropdown.classList.remove('PageCopyDropdown__menu--open');
    }
  });

  // Handle copy to clipboard
  copyButton.addEventListener('click', async (e) => {
    e.preventDefault();
    dropdown.classList.remove('PageCopyDropdown__menu--open');
    
    try {
      // Fetch the markdown content from the .md URL
      const currentUrl = window.location.pathname;
      const markdownUrl = currentUrl + '.md';
      
      const response = await fetch(markdownUrl);
      if (!response.ok) throw new Error('Failed to fetch markdown');
      
      const markdownContent = await response.text();
      await navigator.clipboard.writeText(markdownContent);
      
      // Update button to show success
      const originalContent = copyButton.innerHTML;
      copyButton.innerHTML = `${checkedCircleIcon} Copied!`;
      copyButton.classList.add('PageCopyDropdown__copy--success');
      
      setTimeout(() => {
        copyButton.innerHTML = originalContent;
        copyButton.classList.remove('PageCopyDropdown__copy--success');
      }, COPY_TIMEOUT);
      
    } catch (error) {
      console.error('Failed to copy markdown:', error);
      
      // Show error state
      const originalContent = copyButton.innerHTML;
      copyButton.innerHTML = `${clipboardDocumentIcon} Copy failed`;
      copyButton.classList.add('PageCopyDropdown__copy--error');
      
      setTimeout(() => {
        copyButton.innerHTML = originalContent;
        copyButton.classList.remove('PageCopyDropdown__copy--error');
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
}
