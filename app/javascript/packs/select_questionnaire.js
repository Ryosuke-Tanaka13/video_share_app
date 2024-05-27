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
      sessionStorage.setItem('flashMessage', 'アンケートを選択しました。');

      if (!popupBeforeVideo || !popupAfterVideo) {
        console.error('Popup parameters missing');
        return;
      }

      // セッションストレージにデータを保存
      sessionStorage.setItem('selectedQuestionnaireId', selectedQuestionnaireId);
      sessionStorage.setItem('questionnaireType', type);

      // クエリパラメータを使用して videos/new へのリダイレクト
      var redirectUrl = '/videos/new?popup_before_video=' + popupBeforeVideo + '&popup_after_video=' + popupAfterVideo;
      console.log('Redirect URL:', redirectUrl);
      window.location.href = redirectUrl;
    });

    link.addEventListener('ajax:error', function(event) {
      console.error('AJAX Error:', event.detail);
    });
  });
});
