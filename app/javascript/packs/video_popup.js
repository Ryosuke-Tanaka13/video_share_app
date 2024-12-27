document.addEventListener("turbolinks:load", function() {
  const hiddenLink = document.getElementById('hiddenPopupBeforeLink');
  // ページを開いてすぐ発火
  if (hiddenLink) {
    hiddenLink.click();
  }
});