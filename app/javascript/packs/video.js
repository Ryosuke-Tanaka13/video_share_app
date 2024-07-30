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

    $(document).on('change', '#range', function() {
      if ($(this).val() == '1') { // '限定公開'が選択された場合
        $('#group_field').show(); // グループ選択フィールドを表示
      } else {
        $('#group_field').hide(); // グループ選択フィールドを非表示
      }
    });
  });
});