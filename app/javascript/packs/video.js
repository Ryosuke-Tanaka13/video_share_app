document.addEventListener("turbolinks:load", function() {
  jQuery(function($){
    // フォームデータの一時保存と復元
    const formFields = ['title', 'open_period', 'range', 'comment_public', 'login_set', 'popup_before_video', 'popup_after_video'];

    function saveFormData() {
      // 各フォームフィールドの値をsessionStorageに保存
      formFields.forEach(function(field) {
        const element = document.getElementById(field);
        if (element) {
          sessionStorage.setItem(field, element.value);
        }
      });
    }

    function restoreFormData() {
      // 保存されたフォームフィールドの値を復元
      formFields.forEach(function(field) {
        const element = document.getElementById(field);
        if (element && sessionStorage.getItem(field)) {
          element.value = sessionStorage.getItem(field);
        }
      });
    }

    function clearFormData() {
      // フォームデータとプレビューをクリア
      formFields.forEach(function(field) {
        sessionStorage.removeItem(field);
      });
      sessionStorage.removeItem('videoPreview');
    }

    restoreFormData();

    // プレビューを復元
    const videoPreview = sessionStorage.getItem('videoPreview');
    if (videoPreview) {
      $('#show').html('<video src="' + videoPreview + '" controls />');
    }

    $('#post').change(function(){
      saveFormData();
      // プレビューのvideoタグを削除
      $('video').remove();
      // 投稿されたファイルの1つ目をfileと置く。
      const file = $("#post").prop('files')[0];
      // 以下プレビュー表示のための記述
      const fileReader = new FileReader();
      // videoタグを生成しプレビューを表示(データのURLを出力)
      fileReader.onloadend = function() {
        const videoURL = fileReader.result;
        $('#show').html('<video src="' + videoURL + '" controls />');
        sessionStorage.setItem('videoPreview', videoURL);
      }
      // 読み込みを実行
      fileReader.readAsDataURL(file);
    });

    // アンケート選択ボタンの表示/非表示を切り替える
    toggleQuestionnaireButtons();

    // ポップアップ表示のフィールドを監視
    $(document).on('change', '#popup_before_video', function() {
      toggleQuestionnaireButtons();
    });

    $(document).on('change', '#popup_after_video', function() {
      toggleQuestionnaireButtons();
    });

    function toggleQuestionnaireButtons() {
      // ポップアップの設定に応じて、アンケート選択ボタンの表示を切り替え
      var beforeVideo = $('#popup_before_video').val();
      var afterVideo = $('#popup_after_video').val();

      if (beforeVideo == '1' && afterVideo == '0') {
        $('#select-questionnaire-before').show();
        $('#select-questionnaire-after').hide();
      } else if (beforeVideo == '1' && afterVideo == '1') {
        $('#select-questionnaire-before').show();
        $('#select-questionnaire-after').show();
      } else if (beforeVideo == '0' && afterVideo == '1') {
        $('#select-questionnaire-after').show();
        $('#select-questionnaire-before').hide();
      } else {
        $('#select-questionnaire-before').hide();
        $('#select-questionnaire-after').hide();
      }
    }

    // アンケート選択時の処理
    document.querySelectorAll('a[id^="select-"][id$="-video-questionnaire"]').forEach(function(link) {
      link.addEventListener('click', function(event) {
        event.preventDefault();

        saveFormData();

        var popupBeforeVideo = document.getElementById('popup_before_video').value;
        var popupAfterVideo = document.getElementById('popup_after_video').value;

        // URLにポップアップの設定をクエリパラメータとして追加
        var url = new URL(link.href);
        url.searchParams.set('popup_before_video', popupBeforeVideo);
        url.searchParams.set('popup_after_video', popupAfterVideo);

        // アンケート選択ページに遷移
        window.location.href = url.toString();
      });
    });

    // フラッシュメッセージの表示
    var flashMessage = JSON.parse(sessionStorage.getItem('flashMessage'));
    if (flashMessage) {
      var flashMessageDiv = document.createElement('div');
      flashMessageDiv.classList.add('flash', 'flash-' + flashMessage.type);
      flashMessageDiv.innerText = flashMessage.message;
      document.getElementById('flash-message').appendChild(flashMessageDiv);
      sessionStorage.removeItem('flashMessage');
    }

    var preVideoField = document.getElementById('pre_video_questionnaire_id');
    var postVideoField = document.getElementById('post_video_questionnaire_id');

    var urlParams = new URLSearchParams(window.location.search);
    var popupBeforeVideo = urlParams.get('popup_before_video');
    var popupAfterVideo = urlParams.get('popup_after_video');

    // ポップアップの設定に応じてセレクトボックスの値を設定
    if (popupBeforeVideo) {
      document.getElementById('popup_before_video').value = popupBeforeVideo;
    }

    if (popupAfterVideo) {
      document.getElementById('popup_after_video').value = popupAfterVideo;
    }

    var preVideoQuestionnaireId = sessionStorage.getItem('preVideoQuestionnaireId');
    var postVideoQuestionnaireId = sessionStorage.getItem('postVideoQuestionnaireId');

    // ビデオ開始前のアンケートIDを設定
    if (preVideoQuestionnaireId) {
      preVideoField.value = preVideoQuestionnaireId;
    }

    // ビデオ終了後のアンケートIDを設定
    if (postVideoQuestionnaireId) {
      postVideoField.value = postVideoQuestionnaireId;
    }

    sessionStorage.removeItem('preVideoQuestionnaireId');
    sessionStorage.removeItem('postVideoQuestionnaireId');

    // フォーム送信が成功した後にデータをクリア
    $('form').on('ajax:success', function() {
      clearFormData();
    });
  });
});
