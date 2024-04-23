export function initToc() {
  const nav = document.querySelector(".Toc");

  if (!nav) {
    return;
  }

  const visibleClass = "Toc__list-item--visible";
  const navPath = nav.querySelector("svg path");
  const navListItems = [...document.querySelectorAll(".Toc__list-item")];

  const items = navListItems.map((listItem) => {
    const anchor = listItem.querySelector("a");
    return { listItem, anchor };
  });

  function drawPath() {
    let path = [];
    let pathIndent;

    items.forEach((item, i) => {
      const x = item.anchor.offsetLeft + 3;
      const y = item.anchor.offsetTop;
      const height = item.anchor.offsetHeight;

      if (i === 0) {
        path.push("M", x, y, "L", x, y + height);
        item.pathStart = 0;
      } else {
        if (pathIndent !== x) path.push("L", pathIndent, y);

        path.push("L", x, y);

        navPath.setAttribute("d", path.join(" "));
        item.pathStart = navPath.getTotalLength() || 0;
        path.push("L", x, y + height);
      }

      pathIndent = x;
      navPath.setAttribute("d", path.join(" "));
      item.pathEnd = navPath.getTotalLength();
    });
  }

  function syncPath(clickedItem = null) {
    const pathLength = navPath.getTotalLength();

    let pathStart = pathLength;
    let pathEnd = 0;
    let lastPathStart, lastPathEnd;
    let visibleItemFound = false;

    if (clickedItem) {
      items.forEach((item) => item.listItem.classList.remove("active"));
      clickedItem.listItem.classList.add("active");
      pathStart = Math.min(clickedItem.pathStart, pathStart);
      pathEnd = Math.max(clickedItem.pathEnd, pathEnd);
      visibleItemFound = true;
    } else {
      items.forEach((item) => {
        // Only make the first visible item active
        item.listItem.classList.remove("active");
        if (visibleItemFound) {
          item.listItem.classList.remove("active");
          return;
        }

        if (item.listItem.classList.contains(visibleClass)) {
          item.listItem.classList.add("active");

          pathStart = Math.min(item.pathStart, pathStart);
          pathEnd = Math.max(item.pathEnd, pathEnd);
          visibleItemFound = true;
        }
      });
    }

    if (visibleItemFound && pathStart < pathEnd) {
      if (pathStart !== lastPathStart || pathEnd !== lastPathEnd) {
        const dashArray = `1 ${pathStart} ${pathEnd - pathStart} ${pathLength}`;

        navPath.style.setProperty("stroke-dashoffset", "1");
        navPath.style.setProperty("stroke-dasharray", dashArray);
        navPath.style.setProperty("opacity", 1);
      }
    } else {
      navPath.style.setProperty("opacity", 0);
    }

    lastPathStart = pathStart;
    lastPathEnd = pathEnd;
  }

  const initCurrentLinkListener = () => {
    const content = document.querySelector(".Page");

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          const id = entry.target.getAttribute("id");

          const link = document.querySelector(`.Toc__link[href="#${id}"]`);
          if (!link) {
            return;
          }

          if (entry.intersectionRatio >= 0.25) {
            link.parentElement.classList.add(visibleClass);
          } else {
            link.parentElement.classList.remove(visibleClass);
          }
        });

        syncPath();
      },
      { rootMargin: `-${content.offsetTop}px 0px 0px 0px`, threshold: 0.25 }
    );

    drawPath();

    document.querySelectorAll("section[id]").forEach((section) => {
      observer.observe(section);
    });

    // Wait for the nav to be ready before animating the path
    setTimeout(() => {
      nav.classList.add("Toc--is-ready");
    }, 100);
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

  // Force the clicked item to be active.
  items.forEach((item) => {
    item.anchor.addEventListener("click", (e) => {
      setTimeout(() => {
        item.listItem.classList.add(visibleClass);
        syncPath(item);
      }, 25);
    });
  });

  initCurrentLinkListener();
  initToggle();
}
