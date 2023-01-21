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
  const micAudio = document.getElementById("mic-audio");
  
  //blobにイベントデータをpush
  function handleDataAvailable(event) {
    if (event.data && event.data.size > 0) {
      recordedBlobs.push(event.data);
    }
  }

  // 音声トラックの取得
  function getAudioTrack() {
    // 以下31～58行　コメントアウト部分はシンセサイザーの音源
    // const audioContext = new AudioContext();
    // const t0 = audioContext.currentTime;
    // let t = 0;
    // const oscillator = audioContext.createOscillator();
    // const gainNode = audioContext.createGain();
   
    // oscillator.type = "square";
    // [440, 480, 440, 480, 420, 500, 420, 500].forEach((s) => {
    //   const vol = 1;
    //   const hz = s;
    //   const d = (60 / 80) * (4 / 4);
    //   const sm = d / 3 > 0.08 ? 0.08 : Number((d / 3).toFixed(5));
    //   oscillator.frequency.setValueAtTime(hz, t0 + t);
    //   gainNode.gain.setValueCurveAtTime([vol * 0.03, vol * 0.025], t0 + t, sm);
    //   gainNode.gain.setValueCurveAtTime(
    //     [vol * 0.025, vol * 0.01],
    //     t0 + t + d - sm,
    //     sm
    //   );
    //   t += d;
    // });
    // oscillator.start(t0);
    // oscillator.stop(t0 + t);
    // oscillator.connect(gainNode);
  
    // var streamDestination = audioContext.createMediaStreamDestination();
    // gainNode.connect(streamDestination);
    // return streamDestination.stream.getTracks()[0];


    // 以下61~67行　micAudioの音声データのトラック抽出
    const audioContext = new AudioContext();
    const sourceNode = audioContext.createMediaElementSource(micAudio);
    sourceNode.connect(audioContext.destination);
    var streamDestination = audioContext.createMediaStreamDestination();
    sourceNode.connect(streamDestination);
    return streamDestination.stream.getTracks()[0];
  };

  // 録画開始ボタン開始をクリックで発火 → キャンバス映像と音声データの合成
  function startRecording() {
    const ms = new MediaStream();
    ms.addTrack(canvasStream.getTracks()[0]);
    ms.addTrack(getAudioTrack());
    console.log(ms);

    recordedBlobs = [];
    const options = { mimeType: "video/webm;codecs=vp9" };
  
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
  
  // ダウンロードボタンクリックで発火 → blob格納からurl定義し、ダウンロードされる
  downloadButton.addEventListener("click", () => {
    const blob = new Blob(recordedBlobs, { type: "video/webm" });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.style.display = "none";
    a.href = url;
    a.download = "rec.webm";
    document.body.appendChild(a);
    a.click();
    setTimeout(() => {
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
    }, 100);
  });

  // 画面キャプチャの設定の定義
  const displayMediaOptions = {
    video: {
        cursor: "always"
    },
    audio: true
  };
  // デバイス取得ボタンを定義
  const streamButton = document.getElementById("stream");
  // キャンバス伝達変数にnullを代入
  let canvasStream = null;

  // ストリームボタンクリックで発火 → 
  streamButton.addEventListener("click", () => {
    // デバイスリストの表示
    getDeviceList();
    // 録画ボタンの無効化
    recordButton.disabled = false;
    // カメラ映像取得
    navigator.mediaDevices
      .getUserMedia({video: true})
      .then(stream => {
        webCamera.srcObject = stream;
      })
      .catch(e => alert("error" + e.message));

    // 画面キャプチャ映像取得
    navigator.mediaDevices
      .getDisplayMedia(displayMediaOptions)
      .then(stream => {
        screenCapture.srcObject = stream;
      })
      .catch(e => alert("error" + e.message));

    // マイクデバイス音声取得
    navigator.mediaDevices
      .getUserMedia({ audio: true })
      .then(Stream => {
        micAudio.srcObject = Stream;
      })
      .catch(e => alert("error" + e.message));
      
    // キャンバスの描画を走らす
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

  // デバイス情報（マイク・カメラ）をクリアするメソッド
  function clearDeviceList() {
    while(micList.lastChild) {
    micList.removeChild(micList.lastChild);
    }
    while(cameraList.lastChild) {
    cameraList.removeChild(cameraList.lastChild);
    }
  }

  // デバイスをリストへ追加するメソッド
  function addDevice(device) {
    if (device.kind === 'audioinput') {
      var id = device.deviceId;
      var label = device.label || 'microphone'; // label is available for https 
      var option = document.createElement('option');
      option.setAttribute('value', id);
      option.innerHTML = label + '(' + id + ')';;
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

  // デバイスリストを取得するメソッド
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
    console.error('enumerateDevide ERROR:', err);
    });
  }

  // カメラデバイスを取得するメソッド
    function getSelectedVideo() {
    var id = cameraList.options[cameraList.selectedIndex].value;
    return id;
  }

  // マイクデバイスを取得するメソッド
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

  // 選択したメソッドを反映する
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
