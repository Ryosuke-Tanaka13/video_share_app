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

    
    // ポップアップ表示のフィールドを監視
    $(document).on('change', '#popup_before_video', function() {
      if ($(this).val() == '1') {
        $('#select-questionnaire-before').show(); // アンケート選択ボタンを表示
      } else {
        $('#select-questionnaire-before').hide(); // アンケート選択ボタンを非表示
      }
    });

    $(document).on('change', '#popup_after_video', function() {
      if ($(this).val() == '1') {
        $('#select-questionnaire-after').show(); // アンケート選択ボタンを表示
      } else {
        $('#select-questionnaire-after').hide(); // アンケート選択ボタンを非表示
      }
    });
  });
});