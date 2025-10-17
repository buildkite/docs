export function bindToggles() {
  const toggleNodes = Array.from(
    document.getElementsByClassName("Nav__toggle")
  );

  toggleNodes.map(
    (toggle) =>
      (toggle.onclick = function (e) {
        const currentLevel = parseInt(
          e.target.getAttribute("data-toggle-nav-level")
        );
        const sectionNodes = Array.from(
          document.getElementsByClassName(
            `Nav__section--level${currentLevel + 1}`
          )
        );

        function collapse() {
          e.target.nextSibling.nextSibling.classList.remove(
            "Nav__section--show"
          );
          e.target.classList.remove("Nav__toggle--on");
        }

        function expand() {
          e.target.nextSibling.nextSibling.classList.add("Nav__section--show");
          e.target.classList.add("Nav__toggle--on");
        }

        if (e.target.className.includes("Nav__toggle--on")) {
          collapse();
        } else {
          expand();
        }

        if (window.matchMedia("screen and (max-width: 959px)").matches) {
          window.scrollTo({
            top: e.target.offsetTop,
            behavior: "smooth",
          });
        }
      })
  );
}

export function preserveScroll() {
  const navContainer = document.querySelector(".Page__sidebar");
  const storageKey = "navScrollTop";

  if (!navContainer) {
    return;
  }

  // On page load, restore the scroll position from sessionStorage
  const savedScrollTop = sessionStorage.getItem(storageKey);
  if (savedScrollTop) {
    navContainer.scrollTop = parseInt(savedScrollTop, 10);
  }

  // Before leaving the page, save the current scroll position.
  // turbo:before-visit is the Turbo event for this.
  document.addEventListener("turbo:before-visit", () => {
    sessionStorage.setItem(storageKey, navContainer.scrollTop);
  });
}
