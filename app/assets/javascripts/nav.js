(function() {
  const currentNode = Array.from(document.getElementsByClassName('Nav__link--current')).pop();

  setCurrentNavs(currentNode);

  function setCurrentNavs (currentNode) {
    const parentNode = currentNode.parentNode

    if (parentNode.className.includes('Nav')) {
      if (parentNode.className.includes('Nav__section')) {
        parentNode.classList.add('Nav__section--current');
      }
      if (parentNode.className.includes('Nav__item')) {
        parentNode.classList.add('Nav__item--current')
      }
      setCurrentNavs(parentNode);
    }
  }
})();
