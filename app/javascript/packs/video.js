document.addEventListener("turbolinks:load", function() {
  jQuery(function($){
    $('#post').change(function(){
      // プレビューのvideoタグを削除
      $('video').remove();
      // 投稿されたファイルの1つ目をfileと置く。
      const file = $("#post").prop('files')[0];
      // 以下プレビュー表示のための記述
      const fileReader = new FileReader();
      // videoタグを生成しプレビューを表示(データのURLを出力)
      fileReader.onloadend = function() {
        $('#show').html('<video src="' + fileReader.result + '"/>');
      }
      // 読み込みを実行
      fileReader.readAsDataURL(file);
    });

    // 初期状態をチェックしてボタンを表示/非表示
    toggleQuestionnaireButtons();

    // ポップアップ表示のフィールドを監視
    $(document).on('change', '#popup_before_video', function() {
      toggleQuestionnaireButtons();
    });

    $(document).on('change', '#popup_after_video', function() {
      toggleQuestionnaireButtons();
    });

    function toggleQuestionnaireButtons() {
      var beforeVideo = $('#popup_before_video').val();
      var afterVideo = $('#popup_after_video').val();

      if (beforeVideo == '1' && afterVideo == '0') {
        $('#select-questionnaire-before').show();
        $('#select-questionnaire-after').hide();
      } else if (beforeVideo == '1' && afterVideo == '1') {
        $('#select-questionnaire-before').show();
        $('#select-questionnaire-after').hide();
      } else if (beforeVideo == '0' && afterVideo == '1') {
        $('#select-questionnaire-after').show();
        $('#select-questionnaire-before').hide();
      } else {
        $('#select-questionnaire-before').hide();
        $('#select-questionnaire-after').hide();
      }
    }
  });
});
