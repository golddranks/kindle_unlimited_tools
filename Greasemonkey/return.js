// ==UserScript==
// @name     Return selected Kindle Unlimited
// @version  1
// @grant    none
// @match https://www.amazon.co.jp/kindle-dbs/ku/ku-central/*return*
// ==/UserScript==

const ids = (new URLSearchParams(window.location.search).get("ids") || "")
  .split(",")
  .filter(Boolean);

const perform = () => {
  const returnButtons = document.querySelectorAll("input[type='submit']");
  Array.from(returnButtons)
    .filter(
      (el) =>
        el.value === "利用を終了" &&
        el.hasAttribute("aria-labelledby") &&
        el.offsetParent != null,
    )
    .forEach((el) => {
      const label = el.getAttribute("aria-labelledby");
      if (ids.some((id) => label.includes(id))) {
        console.log("Clicking returning submit for", label);
        el.click();
      }
    });

  const returnButtonSpans = document.querySelectorAll("span");
  Array.from(returnButtonSpans)
    .filter(
      (el) =>
        el.textContent === "利用を終了" && el.id && el.offsetParent != null,
    )
    .forEach((el) => {
      if (ids.some((id) => el?.id.includes(id))) {
        console.log("Clicking returning label for", el.id);
        el.click();
      }
    });
};

if (ids.length > 0) {
  perform();
  setInterval(perform, 3000);
}
