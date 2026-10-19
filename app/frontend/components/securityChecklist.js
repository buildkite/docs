// Enhance the Markdown catalogue without maintaining a second set of controls.
export function initSecurityChecklist() {
  const areas = [...document.querySelectorAll("[data-security-area]")];
  if (!areas.length && !document.querySelector('h2[id="audit-this-area"]'))
    return;

  const storageNotice = document.querySelector("[data-security-storage]");
  const storageUnavailable = () => {
    storageNotice.textContent =
      "Browser storage is unavailable. Selections will not be saved after you leave this page.";
  };

  // Keep legacy anchors with their sections, outside the preceding audit tabs.
  for (const area of areas) {
    if (area.classList.contains("SecurityChecklist")) continue;
    const section = document
      .querySelector(`h2[id="${area.dataset.securityArea}"]`)
      .closest("section");
    const previous = section.previousElementSibling;
    let alias = previous?.lastElementChild;
    while (
      alias &&
      !alias.textContent.trim() &&
      (alias.matches("a[id]") || alias.querySelector("a[id]"))
    ) {
      section.prepend(alias);
      alias = previous.lastElementChild;
    }
  }

  for (const [index, area] of areas.entries()) {
    if (area.classList.contains("SecurityChecklist")) continue;
    const heading = document.querySelector(
      `h2[id="${area.dataset.securityArea}"]`,
    );
    const section = heading.closest("section");
    const group = document.createElement("details");
    group.className = "SecurityChecklist";
    group.open = true;
    group.dataset.securityArea = area.dataset.securityArea;
    section.before(group);
    const progress = document.createElement("p");
    progress.className = "SecurityChecklist__progress";
    const count = document.createElement("span");
    count.className = "SecurityChecklist__count";
    count.setAttribute("aria-live", "polite");
    const auditLink = document.createElement("a");
    auditLink.href = `#${area.dataset.securityArea}-audit-this-area`;
    auditLink.dataset.turbo = "false";
    auditLink.textContent = "Audit this area";
    progress.append(auditLink);
    heading.after(progress);

    let current = section;
    do {
      const next = current.nextElementSibling;
      group.append(current);
      current = next;
    } while (current && !current.querySelector(":scope > h2"));

    const summary = document.createElement("summary");
    // The summary toggles the card; its heading must not navigate to itself.
    heading.textContent = heading.textContent;
    const description = document.createElement("span");
    description.className = "SecurityChecklist__description";
    description.textContent = area.dataset.securitySummary;
    summary.append(heading, description, count);
    group.prepend(summary);

    let tier;
    let controlGroup;
    for (const element of group.querySelectorAll("h3, h4, ul > li")) {
      if (element.matches("h3, h4")) {
        tier = element.textContent.trim();
        if (element.matches("h3")) controlGroup = element.id;
        continue;
      }
      const label = element.querySelector(":scope > strong");
      if (!label) continue;
      const checkbox = document.createElement("input");
      checkbox.type = "checkbox";
      checkbox.dataset.securityKey = `${controlGroup}:${label.textContent}`;
      checkbox.dataset.baseline = String(tier === "Baseline");
      checkbox.setAttribute("aria-label", label.textContent.replace(/:$/, ""));
      element.classList.add("SecurityChecklist__control");
      element.prepend(checkbox);
    }
    area.remove();
    areas[index] = group;
  }

  for (const heading of document.querySelectorAll(
    '.SecurityChecklist h3[id$="-audit-this-area"], .Article h2[id="audit-this-area"]',
  )) {
    const section = heading.closest("section");
    if (section.querySelector('[role="tablist"]')) continue;
    // Standalone audits have H3 sections beside their H2; keep them together.
    if (heading.matches("h2")) {
      let next = section.nextElementSibling;
      while (next && !next.querySelector(":scope > h2")) {
        section.append(next);
        next = section.nextElementSibling;
      }
    }
    section.classList.add("SecurityAudit");
    const tabs = document.createElement("div");
    tabs.className = "SecurityAudit__tabs";
    tabs.setAttribute("role", "tablist");
    tabs.setAttribute("aria-label", heading.textContent);
    const panels = [];
    for (const [index, label] of [
      ...section.querySelectorAll(heading.matches("h2") ? "h3" : "h4"),
    ].entries()) {
      const panel = label.matches("h3")
        ? label.closest("section")
        : document.createElement("div");
      if (label.matches("h4")) {
        let current = label;
        do {
          const next = current.nextElementSibling;
          panel.append(current);
          current = next;
        } while (current && !current.matches("h4"));
      }
      // Match the audit layout: example first, explanatory text below it.
      const example = panel.querySelector(":scope > .highlight");
      if (example) label.after(example);
      const tab = document.createElement("button");
      tab.type = "button";
      tab.textContent = label.textContent;
      label.id = `${heading.id}-${label.textContent.toLowerCase().replaceAll(" ", "-")}`;
      tab.id = `${heading.id}-tab-${index}`;
      panel.id = `${heading.id}-panel-${index}`;
      tab.setAttribute("role", "tab");
      tab.setAttribute("aria-controls", panel.id);
      tab.setAttribute("aria-selected", String(index === 0));
      tab.tabIndex = index === 0 ? 0 : -1;
      panel.setAttribute("role", "tabpanel");
      panel.setAttribute("aria-labelledby", tab.id);
      panel.tabIndex = 0;
      panel.hidden = index !== 0;
      label.hidden = true;
      tabs.append(tab);
      panels.push(panel);
    }
    heading.after(tabs);
    tabs.after(...panels);
  }

  const selectTab = (tab) => {
    for (const sibling of tab.parentElement.children) {
      const selected = sibling === tab;
      sibling.setAttribute("aria-selected", String(selected));
      sibling.tabIndex = selected ? 0 : -1;
      document.getElementById(sibling.getAttribute("aria-controls")).hidden =
        !selected;
    }
  };
  const clickTab = (event) => {
    const tab = event.target.closest('.SecurityAudit [role="tab"]');
    if (tab) selectTab(tab);
  };
  const navigateTabs = (event) => {
    const tab = event.target.closest('.SecurityAudit [role="tab"]');
    if (!tab) return;
    const tabs = [...tab.parentElement.children];
    const index = tabs.indexOf(tab);
    const target = {
      ArrowRight: tabs[(index + 1) % tabs.length],
      ArrowLeft: tabs[(index + tabs.length - 1) % tabs.length],
      Home: tabs[0],
      End: tabs[tabs.length - 1],
    }[event.key];
    if (!target) return;
    event.preventDefault();
    selectTab(target);
    target.focus();
  };

  const updateCount = (area) => {
    const inputs = [...area.querySelectorAll("input[data-security-key]")];
    const checked = inputs.filter((input) => input.checked).length;
    const baseline = inputs.filter(
      (input) => input.dataset.baseline === "true",
    ).length;
    area.querySelector(".SecurityChecklist__count").textContent =
      `${checked}/${inputs.length} checked · ${baseline} baseline`;
  };
  const key = (input) =>
    `buildkite-security-checklist:v1:${input.dataset.securityKey}`;
  for (const area of areas) {
    for (const input of area.querySelectorAll("input[data-security-key]")) {
      try {
        input.checked = localStorage.getItem(key(input)) === "true";
      } catch {
        storageUnavailable();
      }
    }
    updateCount(area);
  }

  const change = (event) => {
    const input = event.target;
    if (!input.matches("input[data-security-key]")) return;
    try {
      if (input.checked) localStorage.setItem(key(input), "true");
      else localStorage.removeItem(key(input));
    } catch {
      storageUnavailable();
    }
    updateCount(input.closest("[data-security-area]"));
  };
  const revealFragment = () => {
    const target = document.getElementById(location.hash.slice(1));
    const group = target?.closest("details.SecurityChecklist");
    if (group) group.open = true;
    const panel = target?.closest('[role="tabpanel"]');
    if (panel) {
      selectTab(document.getElementById(panel.getAttribute("aria-labelledby")));
    }
    (target?.hidden ? panel : target)?.scrollIntoView();
  };
  document.addEventListener("change", change);
  document.addEventListener("click", clickTab);
  document.addEventListener("keydown", navigateTabs);
  window.addEventListener("hashchange", revealFragment);
  revealFragment();
  return () => {
    document.removeEventListener("change", change);
    document.removeEventListener("click", clickTab);
    document.removeEventListener("keydown", navigateTabs);
    window.removeEventListener("hashchange", revealFragment);
  };
}
