document.addEventListener('turbolinks:load', function() {
  // データリモートが設定されたリンクにイベントリスナーを追加
  document.querySelectorAll('a[data-remote="true"]').forEach(function(link) {
    link.addEventListener('ajax:success', function(event) {

      // 変数宣言を const で再代入しない変数に変更
      const selectedQuestionnaireId = event.detail[0].id;
      const type = link.dataset.type;

      console.log('Selected Questionnaire ID:', selectedQuestionnaireId);

      // クエリパラメータを取得
      const urlParams = new URLSearchParams(window.location.search);
      const popupBeforeVideo = urlParams.get('popup_before_video');
      const popupAfterVideo = urlParams.get('popup_after_video');

      // クエリパラメータが存在しない場合のエラーハンドリング
      if (!popupBeforeVideo || !popupAfterVideo) {
        console.error('Popup parameters missing');
        return;
      }

      // セッションストレージにデータを保存
      sessionStorage.setItem('preVideoQuestionnaireId', selectedQuestionnaireId);
      sessionStorage.setItem('postVideoQuestionnaireId', selectedQuestionnaireId);

      // フラッシュメッセージをオブジェクトとして保存
      const flashMessage = {
        message: 'アンケートを選択しました。',
        type: 'success'
      };
      sessionStorage.setItem('flashMessage', JSON.stringify(flashMessage));

      // クエリパラメータを使用して videos/new へのリダイレクト
      const redirectUrl = '/videos/new?popup_before_video=' + popupBeforeVideo + '&popup_after_video=' + popupAfterVideo;
      console.log('Redirect URL:', redirectUrl);
      window.location.href = redirectUrl;
    });

    // AJAXエラー時の処理
    link.addEventListener('ajax:error', function(event) {
      console.error('AJAX Error:', event.detail);
    });
  });
});
