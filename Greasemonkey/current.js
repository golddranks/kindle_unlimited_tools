// ==UserScript==
// @name     Show current Kindle Unlimited
// @version  1
// @grant    none
// @match https://www.amazon.co.jp/kindle-dbs/ku/ku-central/*current*
// ==/UserScript==

const perform = () => {
  const select = document.querySelector("#loanStateFilterDropdown");
  const current = Array.from(select.options).find(
    (opt) => opt.text === "現在",
  ).value;
  if (select.value != current) {
    select.value = current;
    select.dispatchEvent(new Event("change", { bubbles: true }));
  }
};

setInterval(perform, 300);
