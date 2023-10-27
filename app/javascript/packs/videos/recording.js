document.addEventListener("turbolinks:load", () => {
    // webカメラ映像
    const webCamera = document.getElementById("web-camera");
    // 画面キャプチャ映像
    const screenCapture = document.getElementById("screen-capture");
    // 録画したビデオ出力
    const recordedVideo = document.getElementById("recorded-video");
    // 録画ボタン
    const recordButton = document.getElementById("record-button");
    // 再生ボタン
    const playButton = document.getElementById("play-button");
    // ダウンロードボタン
    const downloadButton = document.getElementById("download-button");
    // mediastream api 形式の変数
    let mediaRecorder;
    // バイナリデータのフィールド
    let recordedBlobs;
    // ブラウザ音声
    const browserAudio = document.getElementById("browser-audio");
    // マイク音声
    const micAudio = document.getElementById("mic-audio");
  
    // 画面キャプチャ用
    let screenCaptureStream;
    let videoStream;
    let audioStream;
    let audioMicStream;
  
    // カメラ映像取得
    function getWebCamera(webCamera) {
      navigator.mediaDevices
      .getUserMedia({video: true})
      .then(stream => {
        webCamera.srcObject = stream;
      })
      .catch(e => alert("error" + e.message));
      stopWebCameraButton.disabled = false;
    }
    // webカメラOFFボタン
    const stopWebCameraButton = document.getElementById("stop-web-camera");
    // webカメラOFFボタン　→　webカメラ映像が停止する
    stopWebCameraButton.addEventListener("click", stopWebCamera);
      function stopWebCamera() {
      const tracks = webCamera.srcObject.getTracks();
      tracks.forEach(track => track.stop());
      webCamera.srcObject = null; // <video>要素の映像をクリアする
      stopCanvas(); // 映像自体消えないので視覚的に隠す
      stopWebCameraButton.disabled = true;
    }
  
  
    // 画面キャプチャ映像取得
    function getScreenCapture(screenCapture, browserAudio) {
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
          browserAudio.srcObject = audioStream;
        }
        })
      .catch(e => alert("error" + e.message));
      stopScreenCaptureButton.disabled = false;
      stopBrowserAudioButton.disabled = false;
    }
  
    // 画面キャプチャOFFボタン
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
      stopScreenCaptureButton.disabled = true;
    }
  
    // カメラ映像とキャプチャ映像がない場合、出力画面を隠す
    function stopCanvas() {
        if (!webCamera.srcObject && !videoStream) {
        canvas.style.display = "none";
      }
    }
  
    // ブラウザ音声停止ボタンを取得
    const stopBrowserAudioButton = document.getElementById("stopBrowserAudio");
    function stopBrowserAudio(){
      // 音声トラックが存在する場合
      if (audioStream) {
        // 音声トラックを停止
        audioStream.getAudioTracks()[0].stop();
        // 音声トラックをnullに設定
        audioStream = null;
      }
    }
    // ブラウザ音声停止ボタンがクリックされたときの処理
    stopBrowserAudioButton.addEventListener("click", () => {
      stopBrowserAudio();
      stopBrowserAudioButton.disabled = true;
    });
  
    //マイク音声の取得
    function getMicrophoneAudio(micAudio) {
        navigator.mediaDevices.getUserMedia({ audio: true })
          .then(stream => {
            audioMicStream = stream;
            micAudio.srcObject = stream;
          })
          .catch(e => alert("error" + e.message));
          muteButton.disabled = false;     
      }
      // ブラウザ音声停止ボタンを取得
    const muteButton = document.getElementById('muteButton');
    function stopMicAudio(){
      // 音声トラックが存在する場合
      if (audioMicStream) {
        // 音声トラックを停止
        audioMicStream.getAudioTracks()[0].stop();
        // 音声トラックをnullに設定
        audioMicStream = null;
      }
    }
    // ブラウザ音声停止ボタンがクリックされたときの処理
    muteButton.addEventListener("click", () => {
      stopMicAudio();
      muteButton.disabled = true;
    });
  
    //blobにイベントデータをpush
    function handleDataAvailable(event) {
      if (event.data && event.data.size > 0) {
        recordedBlobs.push(event.data);
      }
    }
  
    // Web Audio APIを使用して2つの音声トラックを結合する関数
    function mergeAudioStreams(stream1, stream2) {
      const audioContext = new (window.AudioContext || window.webkitAudioContext)();
      const destination = audioContext.createMediaStreamDestination();
  
      const sourceNode1 = audioContext.createMediaStreamSource(stream1);
      const sourceNode2 = audioContext.createMediaStreamSource(stream2);
  
      const gainNode1 = audioContext.createGain();
      const gainNode2 = audioContext.createGain();
  
      gainNode1.gain.value = 1;
      gainNode2.gain.value = 1;
  
      sourceNode1.connect(gainNode1).connect(destination);
      sourceNode2.connect(gainNode2).connect(destination);
  
      const mergedStream = destination.stream;
  
      return mergedStream;
    }
  
  
    // 録画開始ボタン開始をクリックで発火 → キャンバス映像と音声データの合成
    function startRecording() {
      const ms = new MediaStream();
      const micAudioStream = micAudio.srcObject;
      const browserAudioStream = browserAudio.srcObject;
  
  
      // 映像がない場合はキャンバスを録画しない
      if (webCamera.srcObject || videoStream) {
        ms.addTrack(canvasStream.getTracks()[0]);
      }
  
      // 両方の音声がある場合のみ結合処理を行う
      if (micAudioStream || browserAudioStream) {
        const mergedAudioStream = mergeAudioStreams(micAudioStream, browserAudioStream);
        ms.addTrack(mergedAudioStream.getAudioTracks()[0]);
      }
  
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
  
    // ダウンロードボタンクリックで発火 → blob格納からurlし、ダウンロードされる
    downloadButton.addEventListener("click", () => {
      // const blob = new Blob(recordedBlobs, { type: "video/webm" });
  
      let blob
      if (webCamera.srcObject || videoStream) {
        blob = new Blob(recordedBlobs, { type: "video/webm" });
      } else {
        blob = new Blob(recordedBlobs, { type: "audio/webm" });
      }
  
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
  
  
    // デバイス取得ボタンを
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
      getScreenCapture(screenCapture, browserAudio);
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
      // 30fpsのキャンバスを流す変数を
      canvasStream = canvas.captureStream(30);
      // キャンバスの出力映像
      const videoCanvas = document.getElementById("player-canvas");
      videoCanvas.srcObject = canvasStream;
    }
  
    // マイクリストのid
    const micList = document.getElementById("mic_list");
    // カメラリストのid
    const cameraList = document.getElementById("camera_list");
  
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
        const id = device.deviceId;
        const label = device.label || 'microphone'; // label is available for https 
        const option = document.createElement('option');
        option.setAttribute('value', id);
        option.innerHTML = label + '(' + id + ')';
        micList.appendChild(option);
      }
      else if (device.kind === 'videoinput') {
        const id = device.deviceId;
        const label = device.label || 'camera'; // label is available for https 
        const option = document.createElement('option');
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
      const id = cameraList.options[cameraList.selectedIndex].value;
      return id;
    }
  
    // マイクデバイスを取得
    function getSelectedAudio() {
      const id = micList.options[micList.selectedIndex].value;
      return id;
    }
  
    // デバイス反映ボタン
    const startVideoBtn = document.getElementById("start_video_button");
  
    // デバイス反映ボタンのクリックで発火 →　デバイスの反映 
    startVideoBtn.addEventListener("click", () => {
      startSelectedVideoAudio();
    });
  
    // デバイスの選択を反映する
    function startSelectedVideoAudio() {
      // マイクデバイスのid
      const audioId = getSelectedAudio();
      // カメラデバイスのid
      const deviceId = getSelectedVideo();
      console.log('selected video device id=' + deviceId + ' ,  audio=' + audioId);
  
      // カメラデバイスの制約
      const video_constraints = {
        video: { 
        deviceId: deviceId
        }
      };
      console.log('mediaDevice.getMedia() constraints:', video_constraints);
  
      // マイクデバイスの制約
      const audio_constraints = {
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
