require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require('admin-lte');
require("jquery");

import 'bootstrap';
import '../stylesheets/organizations/folders'; // This file will contain your custom CSS
import "@fortawesome/fontawesome-free/js/all";

document.addEventListener("turbolinks:load", function() {
  jQuery(function($){
    const UserId = $('tr').attr('id');
    if(UserId != ""){
      $('th').click(function(){
        if(!$(this).hasClass('on')){
          $(this).addClass('on');
          var txt = $(this).text();
          const OrganizationId = $(this).attr('id');
          const folderId = $(this).attr('class');
          $(this).html('<input type="text" value='+txt+' style="width: 150px;">');
          $('th > input').focus().blur(function(){
            var inputVal = $(this).val();
            if(inputVal===''){
                inputVal = this.defaultValue;
            };
            $(this).parent().removeClass('on').text(inputVal);

            $.ajax({                         
              url: '/organizations/'+OrganizationId+'/folders/' + folderId,
              type: 'PATCH',                
              data: {                        
                folder: {
                  name: inputVal
                }
              },
              beforeSend: function(xhr) {
                xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'))
              },
            })
          });
        };
      });
    };
  });
})