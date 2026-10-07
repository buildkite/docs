const ATTRIBUTION_VERSION = "1";
const COOKIE_DAYS = 90;
const FIRST_TOUCH_COOKIE = "bk_first_touch";
const LAST_TOUCH_COOKIE = "bk_last_touch";
const MARKETING_ID_COOKIE = "bk_marketing_id";
const TRACKING_ALLOWED_COOKIE = "bk_marketing_tracking_allowed";
const MAX_COOKIE_VALUE_LENGTH = 1800;
const MAX_PROPERTY_LENGTH = 500;
const MAX_POSTHOG_RETRIES = 50;
const INTERNAL_HOST_RE = /(^|\.)buildkite\.com$/i;
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

let postHogRetryCount = 0;
let postHogRetryTimer;

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
  if (!value) return;

  const encodedValue = encodeURIComponent(value);
  if (encodedValue.length > MAX_COOKIE_VALUE_LENGTH) return;

  const expires = new Date();
  expires.setDate(expires.getDate() + COOKIE_DAYS);
  document.cookie = `${name}=${encodedValue}; expires=${expires.toUTCString()}; path=/${cookieDomainAttribute()}; SameSite=Lax; Secure`;
}

function deleteCookie(name) {
  const expired = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 GMT; max-age=0; path=/; SameSite=Lax; Secure`;
  document.cookie = expired;
  if (INTERNAL_HOST_RE.test(window.location.hostname)) {
    document.cookie = `${expired}; domain=.buildkite.com`;
  }
}

function clearAttribution() {
  deleteCookie(FIRST_TOUCH_COOKIE);
  deleteCookie(LAST_TOUCH_COOKIE);
  deleteCookie(MARKETING_ID_COOKIE);
  deleteCookie(TRACKING_ALLOWED_COOKIE);
}

function touchFromCurrentPage() {
  const current = new URLSearchParams(window.location.search);
  const touch = new URLSearchParams();

  TOUCH_KEYS.forEach((key) => {
    const value = sanitize(
      current.get(key) || "",
      key === "utm_source" || key === "utm_medium",
    );
    if (value) touch.set(key, value);
  });

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

  return new URLSearchParams(value);
}

function hasAttribution(touch) {
  return TOUCH_KEYS.some((key) => sanitize(touch.get(key) || ""));
}

function persistTouch(touch) {
  if (!hasAttribution(touch)) return;

  const firstTouch = parseTouch(readCookie(FIRST_TOUCH_COOKIE));
  if (!hasAttribution(firstTouch)) {
    writeCookie(FIRST_TOUCH_COOKIE, touch.toString());
  }
  writeCookie(LAST_TOUCH_COOKIE, touch.toString());
}

function isSignupUrl(url) {
  return (
    INTERNAL_HOST_RE.test(url.hostname) && /^\/signup\/?$/.test(url.pathname)
  );
}

function rewriteSignupLinks(touch) {
  if (!hasAttribution(touch)) return;

  document.querySelectorAll("a[href]").forEach((anchor) => {
    const rawHref = anchor.getAttribute("href");
    if (!rawHref) return;

    let url;
    try {
      url = new URL(rawHref, window.location.origin);
    } catch {
      return;
    }
    if (!isSignupUrl(url)) return;

    TOUCH_KEYS.forEach((key) => {
      const value = touch.get(key);
      if (value && !url.searchParams.has(key)) {
        url.searchParams.set(key, value);
      }
    });
    anchor.setAttribute("href", url.toString());
  });
}

function postHogIsReady() {
  return window.posthog && typeof window.posthog.get_distinct_id === "function";
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
  if (!postHogIsReady()) {
    retryWhenPostHogIsReady();
    return;
  }

  if (
    typeof window.posthog.has_opted_out_capturing === "function" &&
    window.posthog.has_opted_out_capturing()
  ) {
    clearAttribution();
    return;
  }

  const distinctId = sanitize(window.posthog.get_distinct_id());
  if (!distinctId) return;

  const incomingTouch = touchFromCurrentPage();
  persistTouch(incomingTouch);

  const passthrough = hasAttribution(incomingTouch)
    ? incomingTouch
    : parseTouch(readCookie(LAST_TOUCH_COOKIE));

  writeCookie(MARKETING_ID_COOKIE, distinctId);
  writeCookie(TRACKING_ALLOWED_COOKIE, "1");
  rewriteSignupLinks(passthrough);
}
