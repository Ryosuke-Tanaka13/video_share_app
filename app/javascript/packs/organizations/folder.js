document.addEventListener("turbolinks:load", function() {
jQuery(function($){
  $('th').click(function(){
    if(!$(this).hasClass('on')){
      $(this).addClass('on');
      var txt = $(this).text();
      const folderId = $(this).attr('class');
      $(this).html('<input type="text" value='+txt+' style="width: 150px;">');
      $('th > input').focus().blur(function(){
        var inputVal = $(this).val();
        if(inputVal===''){
            inputVal = this.defaultValue;
        };
        $(this).parent().removeClass('on').text(inputVal);

        $.ajax({                         
          url: '/organizations/folders/' + folderId,
          type: 'PATCH',                
          data: {                        
            folder: {
              name: inputVal
            }
          }
        })
      });
    };
  });
});
})