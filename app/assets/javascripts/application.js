window.addEventListener("DOMContentLoaded", () => {
  document.onkeydown = (e) => {
    const event = window.event || e;

    switch (event.keyCode) {
      case 191:
        e.preventDefault();
        document.getElementById("search").focus();
        break;
    }
  };

  // todo: use data attributes
  document.querySelectorAll("[data-copy-to-clipboard-btn]").forEach((el) => {
    el.addEventListener("click", (e) => {
      copyText = el.previousElementSibling.textContent;
      navigator.clipboard.writeText(copyText);
    });
  });
});
