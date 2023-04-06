document.addEventListener("turbolinks:load", () => {
  // webカメラ映像の定義
  const webCamera = document.getElementById("web-camera");
  // 画面キャプチャ映像の定義
  const screenCapture = document.getElementById("screen-capture");
  // 録画したビデオ出力の定義
  const recordedVideo = document.getElementById("recorded-video");
  // 録画ボタンの定義
  const recordButton = document.getElementById("record-button");
  // 再生ボタンの定義
  const playButton = document.getElementById("play-button");
  // ダウンロードボタンの定義
  const downloadButton = document.getElementById("download-button");
  // mediastream api 形式の変数定義
  let mediaRecorder;
  // バイナリデータのフィールド定義
  let recordedBlobs;
  // マイクデバイスの音声プレイヤーの定義
  const audioPlayer = document.getElementById("audioPlayer");
  // マイクデバイスの音声プレイヤーの定義
  const micAudio = document.getElementById("mic-audio");

  // 映像セレクター定義
  const selectVideo = document.getElementById("select-element-video")
  // 音声セレクター定義
  const selectAudio = document.getElementById("select-element-audio")
  
  // 映像セレクターの処理
  selectVideo.addEventListener("change", videoHandleSelection);
  function videoHandleSelection() {
    const selection = document.getElementById("select-element-video").value;
    //　初期化　
    if (webCamera.srcObject && videoStream) { //画面キャプチャとwebカメラ共に出力されている場合
      stopWebCamera(); //webカメラの
      stopScreenCapture(); //画面キャプチャの削除
    } else if (videoStream){
      stopScreenCapture(); //画面キャプチャの削除
    } else if  (webCamera.srcObject){
      stopWebCamera(); //webカメラの削除
      stopScreenCapture(); //画面キャプチャの削除
    }
      
    if (selection === "none") {// 映像なしの場合の処理
      console.log("映像なしを選択しました");

    } else if (selection === "camera-screen") {// Webカメラ + 画面キャプチャの場合の処理
      canvas.style.display = "block"; // キャンバスの再表示
      getWebCamera(webCamera); //webカメラの取得
      getScreenCapture(screenCapture, audioPlayer); //画面キャプチャの取得
      drawCanvasFromVideo(); // キャンバス再描画
      console.log("Webカメラ + 画面キャプチャを選択しました");

    } else if (selection === "camera") {// Webカメラのみの場合の処理
      canvas.style.display = "block"; // キャンバスの再表示
      getWebCamera(webCamera); //webカメラの取得
      drawCanvasFromVideo(); // キャンバス再描画
      console.log("Webカメラのみを選択しました");
      
    } else if (selection === "screen") {// 画面キャプチャのみの場合の処理
      canvas.style.display = "block"; // キャンバスの再表示
      getScreenCapture(screenCapture, audioPlayer); //画面キャプチャの取得
      drawCanvasFromVideo(); // キャンバス再描画
      console.log("画面キャプチャのみを選択しました");
    }
  }

  // 音声セレクターの処理
  selectAudio.addEventListener("change", audioHandleSelection);
  function audioHandleSelection() {
    const selection = document.getElementById("select-element-audio").value;
      
    if (selection === "none") {// 映像なしの場合の処理
      console.log("音声なしを選択しました");
      stopBrowser()

    } else if (selection === "mic-browser") {// Webカメラ + 画面キャプチャの場合の処理
      console.log("マイク音声 + ブラウザ音声を選択しました");

    } else if (selection === "mic") {// Webカメラのみの場合の処理
      console.log("マイク音声のみを選択しました");
      
    } else if (selection === "browser") {// 画面キャプチャのみの場合の処理
      console.log("ブラウザ音声のみを選択しました");
    }
  }

  // 画面キャプチャ用定義
  let screenCaptureStream;
  let videoStream;
  let audioStream;

  // カメラ映像取得
  function getWebCamera(webCamera) {
    navigator.mediaDevices
    .getUserMedia({video: true})
    .then(stream => {
      webCamera.srcObject = stream;
    })
    .catch(e => alert("error" + e.message));
  }
  // webカメラOFFボタン定義
  const stopWebCameraButton = document.getElementById("stop-web-camera");
  // webカメラOFFボタン　→　webカメラ映像が停止する
  stopWebCameraButton.addEventListener("click", stopWebCamera);
    function stopWebCamera() {
    const tracks = webCamera.srcObject.getTracks();
    tracks.forEach(track => track.stop());
    webCamera.srcObject = null; // <video>要素の映像をクリアする
    stopCanvas(); // 映像自体消えないので視覚的に隠す
  }

  
  // 画面キャプチャ映像取得
  function getScreenCapture(screenCapture, audioPlayer) {
    // 画面キャプチャの取得内容設定
    const displayMediaOptions = {
      video: {
          cursor: "always"
      },
      audio: true
    };

    navigator.mediaDevices
    .getDisplayMedia(displayMediaOptions)
    .then(stream => {
      screenCaptureStream = stream;

      // 映像トラックを抽出して、videoタグに設定する
      const videoTracks = stream.getVideoTracks();
      if (videoTracks.length > 0) {
        videoStream = new MediaStream([videoTracks[0]]);
        screenCapture.srcObject = videoStream;
      }
  
      // 音声トラックを抽出して、audioタグに設定する
      const audioTracks = stream.getAudioTracks();
      if (audioTracks.length > 0) {
        audioStream = new MediaStream([audioTracks[0]]);
        audioPlayer.srcObject = audioStream;
      }
      })
    .catch(e => alert("error" + e.message));
  }

  // 画面キャプチャOFFボタン定義
  const stopScreenCaptureButton = document.getElementById("stop-screen-capture");
  // 画面キャプチャOFFボタン押下処理　→　画面キャプチャ映像が停止する
  stopScreenCaptureButton.addEventListener("click", stopScreenCapture);
  function stopScreenCapture() {
     // 映像トラックが存在する場合
    if (videoStream) {
      // 映像トラックを停止
      videoStream.getVideoTracks()[0].stop();
      // 映像トラックをnullに設定
      videoStream = null;
    }
    stopCanvas(); // 映像自体消えないので視覚的に隠す
  }

  // カメラ映像とキャプチャ映像がない場合、出力画面を隠す
  function stopCanvas() {
      if (!webCamera.srcObject && !videoStream) {
      canvas.style.display = "none";
    }
  }

  // 音声停止ボタンを取得
  const stopBrowserAudioButton = document.getElementById("stopBrowserAudio");
  function stopBrowser(){
    // 音声トラックが存在する場合
    if (audioStream) {
      // 音声トラックを停止
      audioStream.getAudioTracks()[0].stop();
      // 音声トラックをnullに設定
      audioStream = null;
    }
  }
  // 音声停止ボタンがクリックされたときの処理
  stopBrowserAudioButton.addEventListener("click", () => {
    stopBrowser()
  });

  // マイクデバイス音声取得
  function getMicrophoneAudio(micAudio) {
    let audioStream;
  
    navigator.mediaDevices.getUserMedia({ audio: true })
      .then(stream => {
        audioStream = stream;
        micAudio.srcObject = stream;
      })
      .catch(e => alert("error" + e.message));
  
    const muteButton = document.getElementById('muteButton');
    muteButton.addEventListener('click', () => {
      // 音声トラックが存在する場合
    if (audioStream) {
      // 音声トラックを停止
      audioStream.getAudioTracks()[0].stop();
      // 音声トラックをnullに設定
      audioStream = null;
    }
    });
  }
  
  //blobにイベントデータをpush
  function handleDataAvailable(event) {
    if (event.data && event.data.size > 0) {
      recordedBlobs.push(event.data);
    }
  }

  // 録画開始ボタン開始をクリックで発火 → キャンバス映像と音声データの合成
  function startRecording() {
    const ms = new MediaStream();
    // 映像がない場合はキャンバスを録画しない
    if (webCamera.srcObject || videoStream) {
      ms.addTrack(canvasStream.getTracks()[0]);
    }
    ms.addTrack(micAudio.srcObject.getTracks()[0]);
    //ms.addTrack(browserAudio.srcObject.getTracks()[0]);

    recordedBlobs = [];
    // const options = { mimeType: "video/webm;codecs=vp9" };
    let options; 
    if (webCamera.srcObject || videoStream) {
      options = { mimeType: "video/webm;codecs=vp9" };
    } else {
      options = { mimeType: "audio/webm" };
    }
  
    try {
      mediaRecorder = new MediaRecorder(ms, options);
    } catch (error) {
      console.log(`Exception while creating MediaRecorder: ${error}`);
      return;
    }
  
    console.log("Created MediaRecorder", mediaRecorder);
    recordButton.textContent = "録画停止";
    playButton.disabled = true;
    downloadButton.disabled = true;
  
    mediaRecorder.onstop = event => {
      console.log("Recorder stopped: ", event);
    };
  
    mediaRecorder.ondataavailable = handleDataAvailable;
    mediaRecorder.start(10);
    console.log("MediaRecorder started", mediaRecorder);
  }
  
  // 録画停止ボタンクリックで発火 → 録画がストップする
  function stopRecording() {
    mediaRecorder.stop();
    console.log("Recorded media.");
  }
  
  // 録画開始ボタンをクリックで発火 → 録画が開始される
  recordButton.addEventListener("click", () => {
    if (recordButton.textContent === "録画開始") {
      clearRecordedVideo();
      startRecording();

    } else {
      stopRecording();
      recordButton.textContent = "録画開始";
      playButton.disabled = false;
      downloadButton.disabled = false;
    }
  });
  
  // 再生ボタンクリックで発火 → blobの拡張子をソース指定してから再生される
  playButton.addEventListener("click", () => {
    const superBuffer = new Blob(recordedBlobs, { type: "video/webm" });
    recordedVideo.src = null;
    recordedVideo.srcObject = null;
    recordedVideo.src = window.URL.createObjectURL(superBuffer);
    recordedVideo.controls = true;
    recordedVideo.play();
  });

  // 録画情報を削除
  function clearRecordedVideo() {
    recordedVideo.pause();
    recordedVideo.src = "";
    recordedVideo.removeAttribute("srcObject");
    recordedVideo.controls = false;
  }
  
  // ダウンロードボタンクリックで発火 → blob格納からurl定義し、ダウンロードされる
  downloadButton.addEventListener("click", () => {
    // const blob = new Blob(recordedBlobs, { type: "video/webm" });

    let blob
    if (webCamera.srcObject || videoStream) {
      blob = new Blob(recordedBlobs, { type: "video/webm" });
    } else {
      blob = new Blob(recordedBlobs, { type: "audio/webm" });
    }

    a.download = "rec.webm";
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.style.display = "none";
    a.href = url;
    document.body.appendChild(a);
    a.click();
    setTimeout(() => {
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
    }, 100);
  });

  
  // デバイス取得ボタンを定義
  const streamButton = document.getElementById("stream");
  // キャンバス伝達変数にnullを代入
  let canvasStream = null;

  // デバイス取得ボタンクリックで発火 → 
  streamButton.addEventListener("click", () => {
    // キャンバスの再表示
    canvas.style.display = "block";
    // デバイスリストの表示
    getDeviceList();
    // 録画ボタンの無効化
    recordButton.disabled = false;

    // webカメラ映像取得
    getWebCamera(webCamera);
    // 画面キャプチャ映像取得(映像, 音声)
    getScreenCapture(screenCapture, audioPlayer);
    // マイクデバイス音声取得
    getMicrophoneAudio(micAudio);
      
    // キャンバスの描画
    drawCanvasFromVideo();
  });
  
  // キャンバスの描画設定
  function drawCanvasFromVideo()  {
    const canvas = document.getElementById("canvas");
    const ctx = canvas.getContext('2d');
    setInterval(() => {
      if (canvas && ctx){
        // 描画サイズと配置
          ctx.drawImage(screenCapture, 0, 0, canvas.width, canvas.height);
          ctx.drawImage(webCamera, 0, 0, 640, 480, 10, 10, 160, 120);
      };
      // キャプチャを選択しない、または共有を停止した際カメラを全画面表示に切替
      if (screenCapture.srcObject == null || screenCapture.networkState == 1){
          ctx.drawImage(webCamera, 0, 0, canvas.width, canvas.height);
      };
    }, 1000/30);
    // 30fpsのキャンバスを流す変数を定義
    canvasStream = canvas.captureStream(30);
    // キャンバスの出力映像の定義
    const videoCanvas = document.getElementById("player-canvas");
    videoCanvas.srcObject = canvasStream;
  }

  // マイクリストのid定義
  var micList = document.getElementById("mic_list");
  // カメラリストのid定義
  var cameraList = document.getElementById("camera_list");

  // デバイス情報（マイク・カメラ）を初期化
  function clearDeviceList() {
    while(micList.lastChild) {
    micList.removeChild(micList.lastChild);
    }
    while(cameraList.lastChild) {
    cameraList.removeChild(cameraList.lastChild);
    }
  }

  // デバイスをリストへ追加する
  function addDevice(device) {
    if (device.kind === 'audioinput') {
      var id = device.deviceId;
      var label = device.label || 'microphone'; // label is available for https 
      var option = document.createElement('option');
      option.setAttribute('value', id);
      option.innerHTML = label + '(' + id + ')';
      micList.appendChild(option);
    }
    else if (device.kind === 'videoinput') {
      var id = device.deviceId;
      var label = device.label || 'camera'; // label is available for https 
      var option = document.createElement('option');
      option.setAttribute('value', id);
      option.innerHTML = label + '(' + id + ')';
      cameraList.appendChild(option);
    }
  }

  // デバイスリストを取得する
  function getDeviceList() {
    clearDeviceList();
    navigator.mediaDevices.enumerateDevices()
    .then(function(devices) {
      devices.forEach(function(device) {
        console.log(device.kind + ": " + device.label +
                    " id = " + device.deviceId);
        addDevice(device);
      });
    })
    .catch(function(err) {
      console.error('enumerateDevice ERROR:', err);
    });
  }
  
  // カメラデバイスを取得する
  function getSelectedVideo() {
    var id = cameraList.options[cameraList.selectedIndex].value;
    return id;
  }

  // マイクデバイスを取得
  function getSelectedAudio() {
    var id = micList.options[micList.selectedIndex].value;
    return id;
  }

  // デバイス反映ボタンの定義
  const startVideoBtn = document.getElementById("start_video_button");
  
  // デバイス反映ボタンのクリックで発火 →　デバイスの反映 
  startVideoBtn.addEventListener("click", () => {
    startSelectedVideoAudio();
  });

  // デバイスの選択を反映する
  function startSelectedVideoAudio() {
    // マイクデバイスのid定義
    var audioId = getSelectedAudio();
    // カメラデバイスのid定義
    var deviceId = getSelectedVideo();
    console.log('selected video device id=' + deviceId + ' ,  audio=' + audioId);
    
    // カメラデバイスの制約定義
    var video_constraints = {
      video: { 
      deviceId: deviceId
      }
    };
    console.log('mediaDevice.getMedia() constraints:', video_constraints);
    
    // マイクデバイスの制約定義
    var audio_constraints = {
      audio: {
      deviceId: audioId
      }
    };
    console.log('mediaDevice.getMedia() constraints:', audio_constraints);
  
    // デバイス選択したカメラ映像の更新
    navigator.mediaDevices.getUserMedia(
    video_constraints
    ).then(function(stream) {
      webCamera.srcObject = stream;
    }).catch(function(err){
    console.error('getUserMedia Err:', err);
    });

    // デバイス選択したマイク音声の更新
    navigator.mediaDevices.getUserMedia(
      audio_constraints
      ).then(function(stream) {
        micAudio.srcObject = stream;
      }).catch(function(err){
      console.error('getUserMedia Err:', err);
      });

    // 更新映像のキャンバス再描画
    drawCanvasFromVideo()
  }

  navigator.mediaDevices.ondevicechange = function (evt) {
    console.log('mediaDevices.ondevicechange() evt:', evt);
  };
});
