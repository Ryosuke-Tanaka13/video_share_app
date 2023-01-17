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
    const latestStartPoint = document.getElementById('latest_start_point').innerHTML;
    const latestEndPoint= document.getElementById('latest_end_point').innerHTML;
    
    $.ajax({
      url: '/videos/'+ videoId + '/video_statuses/' + videostatusId,
      type: "PATCH",
      data: {         
        video_status: {          
          total_time: media.duration,
          // 最新の再生開始地点
          latest_start_point: latestStartPoint,
          // 最新の再生完了地点
          latest_end_point: latestEndPoint,
          video_id: videoId,
          viewer_id: viewerId
        }
      },
      beforeSend: function(xhr) {
        xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'))
      },
    });
  }); 
  
  $(window).on('beforeunload', function(){
    const latestStartPoint = document.getElementById('latest_start_point').innerHTML;
    const latestEndPoint= document.getElementById('latest_end_point').innerHTML;

    $.ajax({
      url: '/videos/'+ videoId + '/video_statuses/' + videostatusId,
      type: "PATCH",
      data: {         
        video_status: {     
          total_time: media.duration,     
          // 最新の再生開始地点
          latest_start_point: latestStartPoint,
          // 最新の再生完了地点
          latest_end_point: latestEndPoint,
          video_id: videoId,
          viewer_id: viewerId
        }
      },
      beforeSend: function(xhr) {
        xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'))
      },
    });
  });
})
