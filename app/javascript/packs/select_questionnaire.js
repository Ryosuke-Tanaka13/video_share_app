document.addEventListener('turbolinks:load', function() {
  document.querySelectorAll('a[data-remote="true"]').forEach(function(link) {
    link.addEventListener('ajax:success', function(event) {
      console.log('AJAX Success:', event.detail);

      var selectedQuestionnaireId = event.detail[0].id;
      var type = link.dataset.type;

      console.log('Selected Questionnaire ID:', selectedQuestionnaireId);
      console.log('Type:', type);

      // クエリパラメータを正しく取得
      var urlParams = new URLSearchParams(window.location.search);
      var popupBeforeVideo = urlParams.get('popup_before_video');
      var popupAfterVideo = urlParams.get('popup_after_video');

      if (!popupBeforeVideo || !popupAfterVideo) {
        console.error('Popup parameters missing');
        return;
      }

      // セッションストレージにデータを保存
      if (type === 'pre_video') {
        sessionStorage.setItem('preVideoQuestionnaireId', selectedQuestionnaireId);
      } else if (type === 'post_video') {
        sessionStorage.setItem('postVideoQuestionnaireId', selectedQuestionnaireId);
      }

      // フラッシュメッセージをオブジェクトとして保存
      var flashMessage = {
        message: 'アンケートを選択しました。',
        type: 'success'
      };
      sessionStorage.setItem('flashMessage', JSON.stringify(flashMessage));

      // クエリパラメータを使用して videos/new へのリダイレクト
      var redirectUrl = '/videos/new?popup_before_video=' + popupBeforeVideo + '&popup_after_video=' + popupAfterVideo;
      console.log('Redirect URL:', redirectUrl);
      window.location.href = redirectUl;
    });

    link.addEventListener('ajax:error', function(event) {
      console.error('AJAX Error:', event.detail);
    });
  });
});
