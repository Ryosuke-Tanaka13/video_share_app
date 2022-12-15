document.addEventListener("turbolinks:load", function(){
  const videoId = $('.video-id').attr('id');
  const viewerId = $('.viewer-id').attr('id');
  const videostatusId = $('.video-status-id').attr('id');
  const media = document.getElementById("mv");
  
  // 動画のメタデータを読み込み完了したタイミングで、動画の総合時間を取得
  media.addEventListener('loadedmetadata', function(){
    document.getElementById('total').innerHTML = media.duration;
  });

  $('#mv').on('pause', function(){
    const firstStartPoint = document.getElementById('latest_start_point').innerHTML;
    const firstEndPoint= document.getElementById('latest_end_point').innerHTML;
  
    if(videostatusId == ''){
      $.ajax({
        url: '/videos/'+ videoId + '/video_statuses/',
        type: "POST",
        data: {         
          video_status: {          
          total_time: media.duration,
          // 1回目の再生開始地点
          latest_start_point: firstStartPoint,
          // １回目の再生完了地点
          latest_end_point: firstEndPoint,
          video_id: videoId,
          viewer_id: viewerId
          }
        },
        beforeSend: function(xhr) {
          xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'))
        },
      });
    } else {
      $.ajax({
        url: '/videos/'+ videoId + '/video_statuses/' + videostatusId,
        type: "PATCH",
        data: {         
          video_status: {          
            total_time: media.duration,
            // 1回目の再生開始地点
            latest_start_point: firstStartPoint,
            // 1回目の再生完了地点
            latest_end_point: firstEndPoint,
            video_id: videoId,
            viewer_id: viewerId
          }
        },
        beforeSend: function(xhr) {
          xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'))
        },
      });
    }
  }); 
  
  $(window).on('beforeunload', function(){
    const firstStartPoint = document.getElementById('latest_start_point').innerHTML;
    const firstEndPoint= document.getElementById('latest_end_point').innerHTML;

     if(videostatusId == ''){
      $.ajax({
        url: '/videos/'+ videoId + '/video_statuses/',
        type: "POST",
        data: {         
          video_status: {          
          total_time: media.duration,
          // 1回目の再生開始地点
          latest_start_point: firstStartPoint,
          // １回目の再生完了地点
          latest_end_point: firstEndPoint,
          video_id: videoId,
          viewer_id: viewerId
          }
        },
        beforeSend: function(xhr) {
          xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'))
        },
      });
    } else {
      $.ajax({
        url: '/videos/'+ videoId + '/video_statuses/' + videostatusId,
        type: "PATCH",
        data: {         
          video_status: {     
            total_time: media.duration,     
            // 1回目の再生開始地点
            latest_start_point: firstStartPoint,
            // 1回目の再生完了地点
            latest_end_point: firstEndPoint,
            video_id: videoId,
            viewer_id: viewerId
          }
        },
        beforeSend: function(xhr) {
          xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'))
        },
      });
    }
  });
})
