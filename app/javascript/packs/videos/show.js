document.addEventListener('turbolinks:load', function() {
  let button = $("#toggle-comments-button");
  let commentsArea = $("#comments_area");

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
});





