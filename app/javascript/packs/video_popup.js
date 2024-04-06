document.addEventListener("turbolinks:load", function() {
  const hiddenLink = document.getElementById('hiddenPopupBeforeLink');
  // ページを開いてすぐ発火
  if (hiddenLink) {
    hiddenLink.click();
  }

  const vimeoPlayer = document.getElementById('vimeoPlayer');
  const player = new Vimeo.Player(vimeoPlayer);

  // 動画を見終わると発火
  player.on('ended', function() {
    const hiddenLink = document.getElementById('hiddenPopupAfterLink');
    if (hiddenLink) {
      hiddenLink.click();
    }
  });
});


