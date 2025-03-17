// ==UserScript==
// @name     Highlight links and backgrounds
// @version  1
// @grant    none
// @match		 https://www.amazon.co.jp/*
// ==/UserScript==

const asins = `B07168N9Q7
B0CBLV4N9M`; // For example

const asinRegex = /B0[0-9A-Z]{8}/g;

const urlMatches = document.URL.match(asinRegex);
if (urlMatches) {
  if (urlMatches.some((m) => asins.includes(m))) {
    document.body.setAttribute("style", "background-color: yellow;");
  }
}

const perform = () => {
  for (const a of document.querySelectorAll("a")) {
    const hrefMatches = a.href.match(asinRegex);
    if (hrefMatches == null) {
      continue;
    }
    console.log("matches", hrefMatches);
    if (hrefMatches.some((m) => asins.includes(m))) {
      a.setAttribute("style", "background-color: yellow;");
    }
  }
};

perform();
