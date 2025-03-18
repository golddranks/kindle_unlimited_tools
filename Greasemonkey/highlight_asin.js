// ==UserScript==
// @name     Highlight links and backgrounds
// @version  1
// @grant    none
// @match		 https://www.amazon.co.jp/*
// ==/UserScript==

const asins = `B07168N9Q7
B0CBLV4N9M`; // For example

const asinRegex = /B0[0-9A-Z]{8}/g;
const comicsRegex = /コミックス|Comics|comics|COMICS/gu;

const urlMatches = document.URL.match(asinRegex);
if (urlMatches) {
  if (urlMatches.some((m) => asins.includes(m))) {
    document.body.setAttribute("style", "background-color: yellow;");
  }
}

const perform = () => {
  for (const a of document.getElementsByTagName("a")) {
    const hrefMatches = a.href.match(asinRegex);
    const comicMatches = a.textContent.match(comicsRegex);
    if (hrefMatches == null && comicMatches == null) {
      continue;
    }
    if (comicMatches) {
      for (const text of a.getElementsByTagName("*")) {
        const textMatches = text.textContent.match(comicsRegex);
        if (textMatches) {
          text.setAttribute("style", "background-color: red;");
        }
      }
    }
    if (hrefMatches.some((m) => asins.includes(m))) {
      a.setAttribute("style", "background-color: yellow;");
    }
  }
};

perform();
setInterval(perform, 2000);
