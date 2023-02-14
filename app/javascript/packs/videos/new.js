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
  });
  
  // 公開期間設定後の対応選択エリア表示・非表示
  jQuery(function($){
    $('#open_period').on('input', function(){
      if ($('#open_period').val()) {
        $('.expire_type_choice').show().css('background-color', '#FFDDFF');
      }else{
        $('.expire_type_choice').hide();
      }
    });

    // バリデーションエラーでrender:newした際に、選択エリアが非表示になるのを防止
    if ($('#open_period').val()) {
      $('.expire_type_choice').show().css('background-color', '#FFDDFF');
    }
  });
})
