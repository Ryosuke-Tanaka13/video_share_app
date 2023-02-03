$(document).on('turbolinks:load', function() {
  // コメント編集エリア表示
  $(function () {
    $(document).on("click", ".js-edit-comment-button", function () {
      const commentId = $(this).data("comment-id");
      const commentLabelArea = $("#js-comment-label-" + commentId);
      const commentTextArea = $("#js-textarea-comment-" + commentId);
      const commentButton = $("#js-comment-button-" + commentId);
      commentLabelArea.hide();
      commentTextArea.show();
      commentButton.show();
    });
  });

  // コメント編集エリア非表示
  $(function () {
    $(document).on("click", ".comment-cancel-button", function () {
      const commentId = $(this).data("cancel-id");
      const commentLabelArea = $("#js-comment-label-" + commentId);
      const commentTextArea = $("#js-textarea-comment-" + commentId);
      const commentButton = $("#js-comment-button-" + commentId);
      const commentError = $("#js-comment-post-error-" + commentId);

      commentLabelArea.show();
      commentTextArea.hide();
      commentButton.hide();
      commentError.hide();
    });
  });

  // コメント更新ボタン
  $(function () {
    $(document).on("click", ".comment-update-button", function () {
      const commentId = $(this).data("update-id");
      const videoId = $(this).data("video-id");
      const textField = $("#js-textarea-comment-" + commentId);
      const updateComment = textField.val();

      $.ajax({
        type: "PATCH",
        url: `/videos/${videoId}/comments/` + commentId,
        data: {
          comment: {
            comment: updateComment,
          },
        },
      })
        .done(function (data) {
          const commentLabelArea = $("#js-comment-label-" + commentId);
          const commentTextArea = $("#js-textarea-comment-" + commentId);
          const commentButton = $("#js-comment-button-" + commentId);
          const commentError = $("#js-comment-post-error-" + commentId);

          commentLabelArea.show();
          commentLabelArea.text(data.comment);
          commentTextArea.hide();
          commentButton.hide();
          commentError.hide();
        })
        .fail(function () {
          const commentError = $("#js-comment-post-error-" + commentId);
          commentError.text("コメントを入力してください");
        });
    });
  });

  // 返信フォーム開閉
  $(function () {
    $(document).on("click", ".js-reply-form-button", function () {
      const commentId = $(this).data("reply-form-id");

      $("#content-show-comment-bottom-reply-form-" + commentId).toggle();
    });
  });

  // 返信内容開閉
  $(function () {
    $(document).on("click", ".js-reply-content-button", function () {
      const commentId = $(this).data("reply-content-id");

      $("#content-show-comment-bottom-reply-content-" + commentId).toggle();
    });
  });

  // 返信編集エリア表示
  $(function () {
    $(document).on("click", ".js-edit-reply-button", function () {
      const replyId = $(this).data("reply-id");
      const replyLabelArea = $("#js-reply-label-" + replyId);
      const replyTextArea = $("#js-textarea-reply-" + replyId);
      const replyButton = $("#js-reply-button-" + replyId);

      replyLabelArea.hide();
      replyTextArea.show();
      replyButton.show();
    });
  });

  // 返信編集エリア非表示
  $(function () {
    $(document).on("click", ".reply-cancel-button", function () {
      const replyId = $(this).data("cancel-id");
      const replyLabelArea = $("#js-reply-label-" + replyId);
      const replyTextArea = $("#js-textarea-reply-" + replyId);
      const replyButton = $("#js-reply-button-" + replyId);
      const replyError = $("#js-reply-post-error-" + replyId);

      replyLabelArea.show();
      replyTextArea.hide();
      replyButton.hide();
      replyError.hide();
    });
  });

  // 返信更新ボタン
  $(function () {
    $(document).on("click", ".reply-update-button", function () {
      const replyId = $(this).data("update-id");
      const videoId = $(this).data("video-id");
      const commentId = $(this).data("comment-id");
      const textField = $("#js-textarea-reply-" + replyId);
      const updateReply = textField.val();

      $.ajax({
        type: "PATCH",
        url: `/videos/${videoId}/comments/${commentId}/replies/` + replyId,
        data: {
          reply: {
            reply: updateReply,
          },
        },
      })
        .done(function (data) {
          const replyLabelArea = $("#js-reply-label-" + replyId);
          const replyTextArea = $("#js-textarea-reply-" + replyId);
          const replyButton = $("#js-reply-button-" + replyId);
          const replyError = $("#js-reply-post-error-" + replyId);

          replyLabelArea.show();
          replyLabelArea.text(data.reply);
          replyTextArea.hide();
          replyButton.hide();
          replyError.hide();
        })
        .fail(function () {
          const replyError = $("#js-reply-post-error-" + replyId);
          replyError.text("返信を入力してください");
        });
    });
  });
});
