document.addEventListener('turbolinks:load', function() {
  const button = $("#toggle-comments-button");
  const commentsArea = $("#comments_area");

  if (button.length && commentsArea.length) {
    button.on("click", function() {
      if (commentsArea.css("display") === "none") {
        commentsArea.show();
        button.text("コメントを非表示にする");
      } else {
        commentsArea.hide();
        button.text("コメントを表示する");
      }
    });
  }
});document.addEventListener("turbolinks:load", function() {
  async function copyUrlToClipboard() {
    try {
      await navigator.clipboard.writeText(location.href);
      // Promiseが解決されるまで待機してから、以下のコードが実行されます
      var wObjballoon = document.getElementById("id-copied");
      wObjballoon.className = "copied-notice";
      setTimeout(function() {
        wObjballoon.className = "copied";
      }, 3000);
    } catch (error) {
      console.error(error);
    }
  }

  // clickイベントが発生した時にcopyUrlToClipboard関数を呼び出します
  var copyBtn = document.getElementById('id-copy-button');
  if (copyBtn) { // copyBtnが存在するか確認
    copyBtn.addEventListener("click", copyUrlToClipboard);
  }
});
