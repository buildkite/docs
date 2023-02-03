"use strict";

(function(window, document) {
  const scrollPadding = 125;
  const currentClassName = 'Toc__link--current';
  const tocLinkNodes = document.querySelectorAll('.Toc__link');
  const headingNodes = document.querySelectorAll('h2.Docs__heading');
  
  const getDistanceFromTop = (element) => {
    if (!element.offsetParent) {
      return element.offsetTop;
    }
    return element.offsetTop + getDistanceFromTop(element.offsetParent);
  };

  const getHeadingPos = (heading) => getDistanceFromTop(heading);

  const setCurrentLink = (hash) => {
    const currentNode = [ ...tocLinkNodes ].find((link) => link.hash === hash);
    
    tocLinkNodes.forEach((link) => link.classList.remove(currentClassName));
    currentNode?.classList.add(currentClassName);
  };

  tocLinkNodes.forEach((link) => {
    link.addEventListener('click', (e) => setCurrentLink(e.target.hash));
  });

  window.addEventListener('scroll', () => {
    const topPos = window.scrollY + scrollPadding;
    
    headingNodes.forEach((heading) => {
      const pos = getHeadingPos(heading);
      if (topPos >= pos) {
        setCurrentLink(`#${heading.id}`);
      }
    });
  });
})(window, document);
