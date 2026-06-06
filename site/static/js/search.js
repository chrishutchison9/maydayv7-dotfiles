function debounce(func, wait) {
  var timeout;

  return function () {
    var context = this;
    var args = arguments;
    clearTimeout(timeout);

    timeout = setTimeout(function () {
      timeout = null;
      func.apply(context, args);
    }, wait);
  };
}

function makeTeaser(body, terms) {
  var TEASER_MAX_CHARS = 200;
  var lowerBody = body.toLowerCase();
  var lowerTerms = terms.map(function (t) {
    return t.toLowerCase();
  });

  // Find the first occurrence of any term
  var firstIndex = -1;
  for (var i = 0; i < lowerTerms.length; i++) {
    var idx = lowerBody.indexOf(lowerTerms[i]);
    if (idx !== -1 && (firstIndex === -1 || idx < firstIndex)) {
      firstIndex = idx;
    }
  }

  // Start a bit before the first match
  var start = Math.max(0, firstIndex - 40);
  var end = Math.min(body.length, start + TEASER_MAX_CHARS);
  var teaser =
    (start > 0 ? "…" : "") +
    body.substring(start, end) +
    (end < body.length ? "…" : "");

  // Bold the matching terms
  for (var i = 0; i < lowerTerms.length; i++) {
    if (lowerTerms[i].length > 0) {
      var regex = new RegExp(
        "(" + lowerTerms[i].replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")",
        "gi",
      );
      teaser = teaser.replace(regex, "<b>$1</b>");
    }
  }

  return teaser;
}

function formatSearchResultItem(item, terms) {
  var body = (item.item.body || "").replace(/§/g, "");
  return (
    '<div class="search-results__item">' +
    `<h1 class='title'>` +
    `<a href="${item.item.url}">${item.item.title}</a>` +
    `</h1>` +
    `<div>${makeTeaser(body, terms)}</div>` +
    `<a href='${item.item.url}'>` +
    `<i>Read More <span class="icon is-small">→</span></i>` +
    `</a>` +
    "</div>"
  );
}

function initSearch() {
  var $searchInput = document.getElementById("search");
  var $searchResults = document.querySelector(".search-results");
  var $searchResultsItems = document.querySelector(".search-results__items");
  var MAX_ITEMS = 10;
  var currentTerm = "";

  var fuse = new Fuse(window.searchIndex, {
    keys: [
      { name: "title", weight: 2 },
      { name: "body", weight: 1 },
    ],
    includeMatches: true,
    minMatchCharLength: 2,
    threshold: 0.3,
    ignoreLocation: true,
  });

  $searchInput.addEventListener(
    "keyup",
    debounce(function () {
      var term = $searchInput.value.trim();
      if (term === currentTerm) {
        return;
      }

      $searchResults.style.display = term === "" ? "none" : "block";
      $searchResultsItems.innerHTML = "";
      if (term === "") {
        currentTerm = "";
        return;
      }

      var results = fuse.search(term);
      if (results.length === 0) {
        $searchResults.style.display = "none";
        currentTerm = term;
        return;
      }

      var number = document.createElement("p");
      number.innerHTML =
        '<div class="search-results__number">' +
        `<b>${results.length}</b> ${
          results.length === 1 ? "result" : "results"
        }` +
        "</div>";
      $searchResultsItems.appendChild(number);

      currentTerm = term;
      for (var i = 0; i < Math.min(results.length, MAX_ITEMS); i++) {
        var item = document.createElement("li");
        item.innerHTML = formatSearchResultItem(results[i], term.split(" "));
        $searchResultsItems.appendChild(item);
      }
    }, 150),
  );

  window.addEventListener("click", function (e) {
    if (
      $searchResults.style.display == "block" &&
      !$searchResults.contains(e.target)
    ) {
      $searchResults.style.display = "none";
    }
  });
}

if (
  document.readyState === "complete" ||
  (document.readyState !== "loading" && !document.documentElement.doScroll)
) {
  initSearch();
} else {
  document.addEventListener("DOMContentLoaded", initSearch);
}
