document.addEventListener('DOMContentLoaded', (event) => {
  let button = document.getElementById("toggle-comments-button");
  let commentsArea = document.getElementById("comments_area");

  if (button && commentsArea) {
    button.addEventListener("click", function() {
      if (commentsArea.style.display === "none") {
        commentsArea.style.display = "block";
        button.textContent = "コメントを非表示にする";
      } else {
        commentsArea.style.display = "none";
        button.textContent = "コメントを表示する";
      }
    });
  }
});
