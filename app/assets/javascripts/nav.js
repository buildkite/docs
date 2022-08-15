(function () {
  const maxWidth = 1536

  initCurrentNavs();
  bindToggles();
  initSidebarsPos();

  function initCurrentNavs () {
    const currentNode = Array.from(document.getElementsByClassName('Nav__link--current')).pop();

    recurseCurrentParentNavs(currentNode);
  }

  function recurseCurrentParentNavs (currentNode) {
    const { parentNode } = currentNode;
    const { className } = parentNode;

    if (className.includes('Nav')) {
      if (className.includes('Nav__section')) {
        parentNode.classList.add('Nav__section--parent', 'Nav__section--show');
      }
      if (className.includes('Nav__item')) {
        parentNode.classList.add('Nav__section--parent', 'Nav__section--show');
        
        const toggleNode = parentNode.querySelector('.Nav__link');
        if (toggleNode) {
          if (toggleNode.className.includes('Nav__toggle')) {
            toggleNode.classList.add('Nav__toggle--on', 'Nav__toggle--parent');
          } else {
            toggleNode.classList.add('Nav__link--parent');
          }
        }
      }

      recurseCurrentParentNavs(parentNode);
    }
  }

  function bindToggles () {
    const toggleNodes = Array.from(document.getElementsByClassName('Nav__toggle'));
    
    toggleNodes.map(toggle => toggle.onclick = function (e) {
      const currentLevel = parseInt(e.target.getAttribute('data-toggle-nav-level'));
      const sectionNodes = Array.from(
        document.getElementsByClassName(`Nav__section--level${currentLevel + 1}`)
      );

      if (e.target.className.includes('Nav__toggle--on')) {
        e.target.nextSibling.nextSibling.classList.remove('Nav__section--show');
        e.target.classList.remove('Nav__toggle--on');
      } else {
        sectionNodes.map(section => section.classList.remove('Nav__section--show'));
        e.target.nextSibling.nextSibling.classList.add('Nav__section--show');
        toggleNodes.map(toggle => {
          if (parseInt(toggle.getAttribute('data-toggle-nav-level')) === currentLevel) {
            toggle.classList.remove('Nav__toggle--on')
          }
        });
        e.target.classList.add('Nav__toggle--on');
      }

      if (window.matchMedia('screen and (max-width: 959px)').matches) {
        window.scrollTo({
          top: e.target.offsetTop,
          behavior: 'smooth'
        });
      }
    });
  }

  function initSidebarsPos () {
    const leftMenuNode = document.querySelector('.Nav__section--level2.Nav__section--show');
    const tocNode = document.querySelector('.Toc');

    if (leftMenuNode || tocNode) {
      setSidebarsPos();
      addEventListener('resize', (event) => setSidebarsPos());
    }

    function setSidebarsPos () {
      const pos = window.innerWidth > maxWidth
        ? Math.floor((window.innerWidth - maxWidth) / 2)
        : 0

      if (leftMenuNode) leftMenuNode.style.left = `${pos}px`;
      if (tocNode) tocNode.style.right = `${pos}px`;
    }
  }
})();
