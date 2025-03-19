// ==UserScript==
// @name     Highlight links and backgrounds
// @version  1
// @grant    none
// @match		 https://www.amazon.co.jp/*
// ==/UserScript==

const asins = `B07168N9Q7
B0CBLV4N9M`; // For example

const asinRegex = /B0[0-9A-Z]{8}/g;
const comicsRegex = /コミック|Comics|comics|COMICS/gu;

const urlAsinMatches = document.URL.match(asinRegex);
const urlComicMatches = document.URL.match(comicsRegex);
if (urlAsinMatches) {
  if (urlAsinMatches.some((m) => asins.includes(m))) {
    document.body.setAttribute("style", "background-color: yellow;");
  }
}
if (urlComicMatches) {
  document.body.setAttribute("style", "background-color: red;");
}

for (const h1 of document.getElementsByTagName("h1")) {
  const headerComicMatches = h1.textContent.match(comicsRegex);
  console.log("h1", h1, h1.textContent, headerComicMatches);
  if (headerComicMatches) {
    h1.setAttribute("style", "background-color: red;");
  }
}

const perform = () => {
  for (const a of document.getElementsByTagName("a")) {
    const hrefMatches = a.href.match(asinRegex);
    const comicMatches = a.textContent.match(comicsRegex);
    console.log(a, a.textContent);
    if (comicMatches) {
      a.setAttribute("style", "background-color: red;");
      for (const text of a.getElementsByTagName("*")) {
        const textMatches = text.textContent.match(comicsRegex);
        console.log(text, textMatches, text.textContent);
        if (textMatches) {
          text.setAttribute("style", "background-color: red;");
        }
      }
    }
    if (hrefMatches) {
      if (hrefMatches.some((m) => asins.includes(m))) {
        a.setAttribute("style", "background-color: yellow;");
      }
    }
  }
};

perform();
setInterval(perform, 2000);
