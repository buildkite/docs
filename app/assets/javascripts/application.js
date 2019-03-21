//= require turbolinks
//= require hoverintent

// Globally track which links have already been prefetched
var prefetched = {};

function prefetch(href) {
  // Don't prefetch anchors
  if (!href.match(/^\//)) {
    return;
  }

  // Don't bother prefetching if we've done so already
  if (prefetched[href]) {
    return;
  }

  // Create our prefetch link tag and add it to the page
  var link = document.createElement("link");
  link.setAttribute("rel", "prefetch");
  link.setAttribute("href", href);
  document.body.appendChild(link);

  // Keep track that we've prefetched this one
  prefetched[href] = true;

  // Return the link for fun and profit (but no profit really...)
  return link;
}

// Fix for in-page anchors triggering Turbolinks. See:
//
// https://github.com/turbolinks/turbolinks/issues/75#issuecomment-445325162
document.addEventListener('turbolinks:click', function (event) {
  var anchorElement = event.target
  var isSamePageAnchor = (
    anchorElement.hash &&
    anchorElement.origin === window.location.origin &&
    anchorElement.pathname === window.location.pathname
  )

  if (isSamePageAnchor) {
    Turbolinks.controller.pushHistoryWithLocationAndRestorationIdentifier(
      event.data.url,
      Turbolinks.uuid()
    )
    event.preventDefault()
  }
})

document.addEventListener("turbolinks:load", function() {
  // Find any links on the page that we should prefetch first if we haven't
  // done so already
  document.querySelectorAll("a[data-prefetch]").forEach(function(a) {
    prefetch(a.getAttribute("href"))
  });

  // Get all the turbolinks links on the page, and setup a hoverintent rule to
  // prefetch the data when you hover over it.
  document.querySelectorAll("a").forEach(function(node) {
    // Not a turoblinks link? Bail.
    if (node.dataset.turbolinks === "false") {
      return;
    }

    hoverintent(node, function() {
      // Prefetch the link when you hover over the link
      prefetch(node.getAttribute("href"));
    }, function() {
      // No action to be taken when you hover out of the link
    }).options({
      // The length of time (in milliseconds) hoverintent waits to re-read mouse
      // coordinates.
      interval: 100,
      // The value (in pixels) the mouse cursor should not travel beyond while
      // hoverintent waits to trigger the mouseover event.
      sensitivity: 5
    });
  });
});
