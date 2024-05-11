document.addEventListener("turbolinks:load", function() {
  const localVideoPlayer = document.getElementById('mv');
  let firstPlay = true;
  
  // 動画が再生される直前に発火
  if (localVideoPlayer) {
    localVideoPlayer.onplay = function() {
      if (firstPlay) {
        const hiddenLink = document.getElementById('hiddenPopupBeforeLink');
        if (hiddenLink) {
          hiddenLink.click();
        }
        localVideoPlayer.pause(); // 動画を停止
        firstPlay = false;
      }
    };
  
    // 動画を見終わると発火
    localVideoPlayer.onended = function() {
      const hiddenLink = document.getElementById('hiddenPopupAfterLink');
      if (hiddenLink) {
        hiddenLink.click();
      }
    };
  }
  });