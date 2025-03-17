// ==UserScript==
// @name     Borrow Kindle Unlimited
// @version  1
// @grant    none
// @match https://www.amazon.co.jp/*/dp/*borrow*
// @match https://www.amazon.co.jp/dp/*borrow*
// ==/UserScript==

const perform = () => {
  let button = document.querySelector("#borrow-button-announce");
  button.click();
};

perform();
setInterval(perform, 2000);
