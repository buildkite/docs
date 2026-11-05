export function initAnimations() {
  const videos = [...document.querySelectorAll("video[data-autoplay]")];
  if (!videos.length) return;

  const controller = new AbortController();
  const { signal } = controller;
  for (const video of videos) {
    const controls = video
      .closest("figure")
      .querySelector("[data-animation-controls]");
    const toggle = controls.querySelector("[data-animation-toggle]");
    // Put controls below the artwork so they never cover the job rows.
    video.controls = false;
    controls.hidden = false;
    const updateLabel = () => {
      toggle.textContent = video.paused ? "Play animation" : "Pause animation";
    };
    const play = () => video.play().catch(() => {});
    toggle.addEventListener(
      "click",
      () => (video.paused ? play() : video.pause()),
      { signal },
    );
    video.addEventListener("play", updateLabel, { signal });
    video.addEventListener("pause", updateLabel, { signal });
    updateLabel();
  }

  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const updatePlayback = () => {
    for (const video of videos) {
      if (reducedMotion.matches) {
        video.pause();
      } else {
        // The play button remains available if the browser blocks autoplay.
        video.play().catch(() => {});
      }
    }
  };

  updatePlayback();
  reducedMotion.addEventListener("change", updatePlayback);
  return () => {
    controller.abort();
    reducedMotion.removeEventListener("change", updatePlayback);
    videos.forEach((video) => video.pause());
  };
}
