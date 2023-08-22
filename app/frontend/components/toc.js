export function initToc() {
  const initCurrentLinkListener = () => {
    const content = document.querySelector(".Page");

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          const id = entry.target.getAttribute("id");

          const link = document.querySelector(`.Toc__link--h2[href="#${id}"]`);
          if (entry.intersectionRatio > 0) {
            link.parentElement.classList.add("Toc__list-item--current");
          } else {
            link.parentElement.classList.remove("Toc__list-item--current");
          }
        });
      },
      { rootMargin: `-${content.offsetTop}px 0px 0px 0px` }
    );

    document.querySelectorAll("section[id]").forEach((sections) => {
      observer.observe(sections);
    });
  };

  const initToggle = () => {
    const toggleNode = document.querySelector(".Toc__toggle");
    const listNode = document.querySelector(".Toc__list");

    if (!toggleNode) {
      return;
    }

    toggleNode.addEventListener("click", (e) => {
      e.target.classList.toggle("Toc__toggle--is-collapsed");
      listNode.classList.toggle("Toc__list--is-collapsed");
    });
  };

  initCurrentLinkListener();
  initToggle();
}
