export function initPageRating() {
  const widget = document.getElementById("page-rating-widget");
  const form = document.getElementById("page-rating-form");
  if (!widget || !form) return;

  let selectedRating = null;
  const buttons = widget.querySelectorAll(".PageRating__button");

  buttons.forEach((button) => {
    button.addEventListener("click", () => {
      selectedRating = parseInt(button.getAttribute("data-rating"), 10);
      buttons.forEach((btn) =>
        btn.classList.remove("PageRating__button--selected"),
      );
      button.classList.add("PageRating__button--selected");
      form.style.display = "block";
    });
  });

  document
    .getElementById("page-rating-submit")
    .addEventListener("click", () => {
      const comment = document
        .getElementById("page-rating-comment")
        .value.trim();
      const email = document.getElementById("page-rating-email").value.trim();

      if (typeof posthog !== "undefined") {
        posthog.capture("docs:page_feedback", {
          rating: selectedRating,
          page_url: window.location.href,
          page_path: window.location.pathname,
          comment: comment || null,
          email: email || null,
        });
      }

      form.style.display = "none";
      widget.innerHTML =
        '<p class="PageRating__thanks">Thanks for your feedback 🙏</p>';
    });
}
