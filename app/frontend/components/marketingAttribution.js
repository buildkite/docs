const ATTRIBUTION_VERSION = "2";
const COOKIE_DAYS = 90;
const FIRST_TOUCH_COOKIE = "bk_first_touch";
const LAST_TOUCH_COOKIE = "bk_last_touch";
const MARKETING_ID_COOKIE = "bk_marketing_id";
const TRACKING_ALLOWED_COOKIE = "bk_marketing_tracking_allowed";
const MARKETING_POSTHOG_TOKEN =
  "phc_md9S7SPscVeXrVuvzDpmvy3FFdaR9rZeaPhUf4vm8LjP";
const MAX_COOKIE_VALUE_LENGTH = 1800;
const MAX_PROPERTY_LENGTH = 500;
const MAX_POSTHOG_RETRIES = 50;
const INTERNAL_HOST_RE = /(^|\.)buildkite\.com$/i;
const LINKEDIN_UTM_SOURCES = [
  "linkedin",
  "linkedin.com",
  "linkedin_ads",
  "linkedin-ads",
  "linkedin_paid",
  "linkedin-paid",
];
const TOUCH_KEYS = [
  "utm_source",
  "utm_medium",
  "utm_campaign",
  "utm_content",
  "utm_term",
  "utm_id",
  "bk_pid",
  "gclid",
  "msclkid",
  "fbclid",
  "li_fat_id",
  "twclid",
  "gbraid",
  "wbraid",
  "gad_source",
  "iaid",
];
const ATTRIBUTION_PROPERTY_KEYS = [
  "first_touch_utm_source",
  "first_touch_utm_medium",
  "first_touch_utm_campaign",
  "first_touch_utm_content",
  "first_touch_utm_term",
  "first_touch_li_fat_id",
  "first_touch_landing_path",
  "first_touch_referring_domain",
  "first_touch_captured_at",
  "last_touch_utm_source",
  "last_touch_utm_medium",
  "last_touch_utm_campaign",
  "last_touch_utm_content",
  "last_touch_utm_term",
  "last_touch_li_fat_id",
  "last_touch_landing_path",
  "last_touch_referring_domain",
  "last_touch_captured_at",
  "marketing_attribution_id",
];

let postHogRetryCount = 0;
let postHogRetryTimer;
let marketingPostHogInitializing = false;
let pendingIncomingTouch = new URLSearchParams();
let lastCapturedPageview = "";
let clickTrackingInitialized = false;

function sanitize(value, lowerCase = false) {
  if (typeof value !== "string") return "";

  const result = value
    .replace(/[\u0000-\u001F\u007F]/g, "")
    .trim()
    .slice(0, MAX_PROPERTY_LENGTH);
  return lowerCase ? result.toLowerCase() : result;
}

function readCookie(name) {
  const prefix = `${name}=`;
  const cookie = document.cookie
    .split("; ")
    .find((candidate) => candidate.startsWith(prefix));

  if (!cookie) return "";

  try {
    return decodeURIComponent(cookie.slice(prefix.length));
  } catch {
    return "";
  }
}

function cookieDomainAttribute() {
  return INTERNAL_HOST_RE.test(window.location.hostname)
    ? "; domain=.buildkite.com"
    : "";
}

function writeCookie(name, value) {
  if (!value) return false;

  try {
    const encodedValue = encodeURIComponent(value);
    if (encodedValue.length > MAX_COOKIE_VALUE_LENGTH) return false;

    const expires = new Date();
    expires.setDate(expires.getDate() + COOKIE_DAYS);
    document.cookie = `${name}=${encodedValue}; expires=${expires.toUTCString()}; path=/${cookieDomainAttribute()}; SameSite=Lax; Secure`;
    return true;
  } catch {
    return false;
  }
}

function deleteCookie(name) {
  const expired = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 GMT; max-age=0; path=/; SameSite=Lax; Secure`;
  document.cookie = expired;
  if (INTERNAL_HOST_RE.test(window.location.hostname)) {
    document.cookie = `${expired}; domain=.buildkite.com`;
  }
}

function restoreRewrittenLinks() {
  document
    .querySelectorAll('a[data-bk-utm-rewritten="1"]')
    .forEach((anchor) => {
      const originalHref = anchor.getAttribute("data-bk-utm-original-href");
      if (originalHref !== null) anchor.setAttribute("href", originalHref);
      anchor.removeAttribute("data-bk-utm-original-href");
      anchor.removeAttribute("data-bk-utm-rewritten");
    });
}

function clearAttribution() {
  deleteCookie(FIRST_TOUCH_COOKIE);
  deleteCookie(LAST_TOUCH_COOKIE);
  deleteCookie(MARKETING_ID_COOKIE);
  deleteCookie(TRACKING_ALLOWED_COOKIE);
  pendingIncomingTouch = new URLSearchParams();
  restoreRewrittenLinks();
}

function docsPostHogIsReady() {
  return Boolean(
    window.posthog &&
    typeof window.posthog.get_distinct_id === "function" &&
    typeof window.posthog.init === "function",
  );
}

function marketingPostHog() {
  return window.posthog?.marketing;
}

function postHogOptedOut() {
  return Boolean(
    window.posthog &&
    typeof window.posthog.has_opted_out_capturing === "function" &&
    window.posthog.has_opted_out_capturing(),
  );
}

function trackingAllowed() {
  if (postHogOptedOut()) {
    clearAttribution();
    return false;
  }

  return readCookie(TRACKING_ALLOWED_COOKIE) === "1";
}

function isValidLinkedInClickId(value) {
  return Boolean(
    typeof value === "string" &&
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
      value,
    ),
  );
}

function safeReferringDomain() {
  if (!document.referrer) return "";

  try {
    const hostname = new URL(document.referrer).hostname;
    return INTERNAL_HOST_RE.test(hostname) ? "" : sanitize(hostname, true);
  } catch {
    return "";
  }
}

function touchFromCurrentPage(includeCookieIdentifiers = false) {
  const current = new URLSearchParams(window.location.search);
  const touch = new URLSearchParams();

  TOUCH_KEYS.forEach((key) => {
    const value = sanitize(
      current.get(key) || "",
      key === "utm_source" || key === "utm_medium",
    );
    if (key === "li_fat_id" && !isValidLinkedInClickId(value)) return;
    if (value) touch.set(key, value);
  });

  const referringDomain = safeReferringDomain();
  const isLinkedInLanding =
    /(^|\.)linkedin\.com$/i.test(referringDomain) ||
    LINKEDIN_UTM_SOURCES.includes(touch.get("utm_source") || "");

  if (
    includeCookieIdentifiers &&
    isLinkedInLanding &&
    !touch.has("li_fat_id") &&
    isValidLinkedInClickId(readCookie("li_fat_id"))
  ) {
    touch.set("li_fat_id", readCookie("li_fat_id"));
  }

  if (referringDomain) touch.set("referring_domain", referringDomain);

  if (touch.toString()) {
    touch.set("v", ATTRIBUTION_VERSION);
    touch.set("captured_at", new Date().toISOString());
    touch.set("landing_path", sanitize(window.location.pathname));
  }

  return touch;
}

function parseTouch(value) {
  if (!value || value.length > MAX_COOKIE_VALUE_LENGTH) {
    return new URLSearchParams();
  }

  try {
    return new URLSearchParams(value);
  } catch {
    return new URLSearchParams();
  }
}

function hasCampaignAttribution(touch) {
  return TOUCH_KEYS.some((key) => sanitize(touch.get(key) || ""));
}

function hasAttribution(touch) {
  return (
    hasCampaignAttribution(touch) ||
    Boolean(sanitize(touch.get("referring_domain") || "", true))
  );
}

function persistTouch(touch) {
  if (!hasAttribution(touch)) return;

  const firstTouch = parseTouch(readCookie(FIRST_TOUCH_COOKIE));
  if (!hasAttribution(firstTouch)) {
    writeCookie(FIRST_TOUCH_COOKIE, touch.toString());
  }
  if (hasCampaignAttribution(touch)) {
    writeCookie(LAST_TOUCH_COOKIE, touch.toString());
  }
}

function touchProperties(prefix, touch) {
  const properties = {};
  [
    "utm_source",
    "utm_medium",
    "utm_campaign",
    "utm_content",
    "utm_term",
    "li_fat_id",
    "landing_path",
    "referring_domain",
    "captured_at",
  ].forEach((key) => {
    const value = sanitize(touch.get(key) || "");
    if (value) properties[`${prefix}_${key}`] = value;
  });
  return properties;
}

function readAttribution() {
  if (!trackingAllowed()) return {};

  const firstTouch = parseTouch(readCookie(FIRST_TOUCH_COOKIE));
  const lastTouch = parseTouch(readCookie(LAST_TOUCH_COOKIE));
  const marketingAttributionId = sanitize(readCookie(MARKETING_ID_COOKIE));

  return {
    attribution_version: ATTRIBUTION_VERSION,
    ...touchProperties("first_touch", firstTouch),
    ...touchProperties("last_touch", lastTouch),
    ...(marketingAttributionId
      ? { marketing_attribution_id: marketingAttributionId }
      : {}),
  };
}

function syncPostHogProperties() {
  const client = marketingPostHog();
  if (!client) return;

  if (typeof client.unregister === "function") {
    ATTRIBUTION_PROPERTY_KEYS.forEach((key) => client.unregister(key));
  }
  if (typeof client.register === "function") {
    client.register(readAttribution());
  }
}

function setCanonicalMarketingId(candidate) {
  const existing = sanitize(readCookie(MARKETING_ID_COOKIE));
  if (existing) return existing;

  const distinctId = sanitize(candidate);
  if (!distinctId) return "";
  writeCookie(MARKETING_ID_COOKIE, distinctId);
  return distinctId;
}

function isSignupUrl(url) {
  return (
    INTERNAL_HOST_RE.test(url.hostname) && /^\/signup\/?$/.test(url.pathname)
  );
}

function rewriteSignupLinks(touch) {
  if (!hasCampaignAttribution(touch)) return;

  document.querySelectorAll("a[href]").forEach((anchor) => {
    const rawHref = anchor.getAttribute("href");
    if (!rawHref || /^(#|javascript:|mailto:|tel:)/i.test(rawHref)) return;

    const baseHref =
      anchor.getAttribute("data-bk-utm-original-href") || rawHref;
    let url;
    try {
      url = new URL(baseHref, window.location.origin);
    } catch {
      return;
    }
    if (!isSignupUrl(url)) return;

    let changed = false;
    TOUCH_KEYS.forEach((key) => {
      const value = touch.get(key);
      if (value && !url.searchParams.has(key)) {
        url.searchParams.set(key, value);
        changed = true;
      }
    });

    if (changed) {
      if (!anchor.hasAttribute("data-bk-utm-original-href")) {
        anchor.setAttribute("data-bk-utm-original-href", rawHref);
      }
      anchor.setAttribute("href", url.toString());
      anchor.setAttribute("data-bk-utm-rewritten", "1");
    }
  });
}

function passthroughTouch(incomingTouch) {
  return hasCampaignAttribution(incomingTouch)
    ? incomingTouch
    : parseTouch(readCookie(LAST_TOUCH_COOKIE));
}

function capturePageview() {
  const client = marketingPostHog();
  if (!client || !trackingAllowed() || typeof client.capture !== "function") {
    return;
  }

  const pageviewKey = window.location.href;
  if (pageviewKey === lastCapturedPageview) return;

  client.capture("$pageview", {
    $current_url: window.location.href,
    $host: window.location.host,
    $pathname: window.location.pathname,
    analytics_surface: "docs",
    ...readAttribution(),
  });
  lastCapturedPageview = pageviewKey;
}

function initializeClickTracking() {
  if (clickTrackingInitialized) return;
  clickTrackingInitialized = true;

  document.addEventListener("click", (event) => {
    if (!trackingAllowed()) return;

    const anchor = event.target?.closest?.("a[href]");
    if (!anchor) return;

    let url;
    try {
      url = new URL(anchor.getAttribute("href") || "", window.location.origin);
    } catch {
      return;
    }
    if (!isSignupUrl(url)) return;

    const client = marketingPostHog();
    if (!client || typeof client.capture !== "function") return;

    const locationElement = anchor.closest("[data-analytics-location]");
    const ctaLocation = locationElement
      ? sanitize(locationElement.getAttribute("data-analytics-location") || "")
      : "unlabeled";

    client.capture("signup_cta_click", {
      analytics_surface: "docs",
      attribution_version: ATTRIBUTION_VERSION,
      cta_location: ctaLocation || "unlabeled",
      destination_path: url.pathname,
      screen_name: window.location.pathname,
      ...readAttribution(),
    });
  });
}

function enableTracking(client) {
  if (postHogOptedOut()) {
    clearAttribution();
    return;
  }

  const canonicalMarketingId = setCanonicalMarketingId(
    client?.get_distinct_id?.() || "",
  );
  if (!canonicalMarketingId) return;

  const incomingTouch = hasAttribution(pendingIncomingTouch)
    ? pendingIncomingTouch
    : touchFromCurrentPage(true);
  persistTouch(incomingTouch);
  writeCookie(TRACKING_ALLOWED_COOKIE, "1");
  syncPostHogProperties();
  rewriteSignupLinks(passthroughTouch(incomingTouch));
  initializeClickTracking();
  capturePageview();
  pendingIncomingTouch = new URLSearchParams();
}

function initializeMarketingPostHog() {
  if (marketingPostHog()) {
    enableTracking(marketingPostHog());
    return;
  }
  if (marketingPostHogInitializing) return;

  marketingPostHogInitializing = true;
  const existingMarketingId = sanitize(readCookie(MARKETING_ID_COOKIE));
  const config = {
    api_host: "https://us.i.posthog.com",
    defaults: "2026-01-30",
    person_profiles: "identified_only",
    persistence: "memory",
    capture_pageview: false,
    capture_pageleave: false,
    autocapture: false,
    disable_session_recording: true,
    disable_surveys: true,
    capture_exceptions: false,
    capture_heatmaps: false,
    capture_performance: false,
    capture_dead_clicks: false,
    ...(existingMarketingId
      ? {
          bootstrap: {
            distinctID: existingMarketingId,
            isIdentifiedID: false,
          },
        }
      : {}),
    loaded(client) {
      marketingPostHogInitializing = false;
      enableTracking(client);
    },
    before_send(event) {
      event.properties ||= {};
      event.properties.analytics_surface = "docs";
      event.properties.attribution_version = ATTRIBUTION_VERSION;
      return event;
    },
  };

  window.posthog.init(MARKETING_POSTHOG_TOKEN, config, "marketing");
}

function retryWhenPostHogIsReady() {
  if (postHogRetryTimer || postHogRetryCount >= MAX_POSTHOG_RETRIES) return;

  postHogRetryTimer = window.setTimeout(() => {
    postHogRetryTimer = undefined;
    postHogRetryCount += 1;
    initMarketingAttribution();
  }, 100);
}

export function initMarketingAttribution() {
  const currentPageTouch = touchFromCurrentPage(false);
  if (hasAttribution(currentPageTouch)) {
    pendingIncomingTouch = currentPageTouch;
  }

  if (!docsPostHogIsReady()) {
    retryWhenPostHogIsReady();
    return;
  }

  if (postHogOptedOut()) {
    clearAttribution();
    return;
  }

  initializeMarketingPostHog();
}

if (typeof window !== "undefined") {
  window.bkMarketingAttribution = {
    clearAttribution,
    readAttribution,
    capturePageview,
  };
}
