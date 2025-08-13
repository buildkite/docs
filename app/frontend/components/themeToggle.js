export function themeToggle() {
  const themeSelect = document.querySelector("#theme-select");

  function setTheme(theme) {
    localStorage.setItem("docs-theme", theme);
    updateAppearance();
  }

  function updateAppearance() {
    let storedTheme = localStorage.getItem("docs-theme") || "system";
    let systemPrefersDark = window.matchMedia(
      "(prefers-color-scheme: dark)",
    ).matches;

    themeSelect.value = storedTheme;
    document
      .querySelectorAll(".theme-icon")
      .forEach((icon) => icon.classList.add("theme-inactive"));

    if (
      storedTheme === "dark" ||
      (storedTheme === "system" && systemPrefersDark)
    ) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }

    document
      .querySelector(`.theme-${storedTheme}`)
      .classList.remove("theme-inactive");
  }

  themeSelect.addEventListener("change", function () {
    setTheme(this.value);
  });

  window.matchMedia("(prefers-color-scheme: dark)").addListener(function () {
    if (localStorage.getItem("docs-theme") === "system") {
      updateAppearance();
    }
  });

  updateAppearance();
}
