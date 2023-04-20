//= require toc

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

  initToc();
});
