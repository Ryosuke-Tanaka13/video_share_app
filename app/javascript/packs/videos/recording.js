document.addEventListener("turbolinks:load", () => {

  // カメラと画面キャプチャの出力
  // 録画
  // 録画の再生
  // 録画のダウンロード
  const localVideo = document.getElementById("local");
  const videoElem = document.getElementById("video");
  const recordedVideo = document.getElementById("recorded");
  const recordBtn = document.getElementById("record");
  const playBtn = document.getElementById("play");
  const downloadBtn = document.getElementById("download");
  let mediaRecorder;
  let recordedBlobs;
  
  function handleDataAvailable(event) {
    if (event.data && event.data.size > 0) {
      recordedBlobs.push(event.data);
    }
  }

  function getAudioTrack() {
    const audioContext = new AudioContext();
    // コメントアウト部分はシンセサイザーの音源
    // const t0 = audioContext.currentTime;
    // let t = 0;
    // const oscillator = audioContext.createOscillator();
    // const gain = audioContext.createGain();
   
    // oscillator.type = "square";
    // [440, 480, 440, 480, 420, 500, 420, 500].forEach((s) => {
    //   const vol = 1;
    //   const hz = s;
    //   const d = (60 / 80) * (4 / 4);
    //   const sm = d / 3 > 0.08 ? 0.08 : Number((d / 3).toFixed(5));
    //   oscillator.frequency.setValueAtTime(hz, t0 + t);
    //   gain.gain.setValueCurveAtTime([vol * 0.03, vol * 0.025], t0 + t, sm);
    //   gain.gain.setValueCurveAtTime(
    //     [vol * 0.025, vol * 0.01],
    //     t0 + t + d - sm,
    //     sm
    //   );
    //   t += d;
    // });
    // oscillator.start(t0);
    // oscillator.stop(t0 + t);
    // oscillator.connect(gain);
    
    const source = audioContext.createMediaElementSource(audioPlayer);
    const gain = audioContext.createGain();
    gain.gain.value = 1;
    
    gain.connect(audioContext.destination);
    source.connect(gain);
   
    var dist = audioContext.createMediaStreamDestination();
    gain.connect(dist);
    return dist.stream.getTracks()[0];
  };

  function startRecording() {
    const ms = new MediaStream();
    ms.addTrack(canvasStream.getTracks()[0]);
    ms.addTrack(getAudioTrack());

    recordedBlobs = [];
    const options = { mimeType: "video/webm;codecs=vp9" };
  
    try {
      mediaRecorder = new MediaRecorder(ms, options);
    } catch (error) {
      console.log(`Exception while creating MediaRecorder: ${error}`);
      return;
    }
  
    console.log("Created MediaRecorder", mediaRecorder);
    recordBtn.textContent = "録画停止";
    playBtn.disabled = true;
    downloadBtn.disabled = true;
  
    mediaRecorder.onstop = event => {
      console.log("Recorder stopped: ", event);
    };
  
    mediaRecorder.ondataavailable = handleDataAvailable;
    mediaRecorder.start(10);
    console.log("MediaRecorder started", mediaRecorder);
  }
  
  function stopRecording() {
    mediaRecorder.stop();
    console.log("Recorded media.");
  }
  
  recordBtn.addEventListener("click", () => {
    if (recordBtn.textContent === "録画開始") {
      startRecording();
      
    } else {
      stopRecording();
      recordBtn.textContent = "録画開始";
      playBtn.disabled = false;
      downloadBtn.disabled = false;
    }
  });
  
  playBtn.addEventListener("click", () => {
    const superBuffer = new Blob(recordedBlobs, { type: "video/webm" });
    recordedVideo.src = null;
    recordedVideo.srcObject = null;
    recordedVideo.src = window.URL.createObjectURL(superBuffer);
    recordedVideo.controls = true;
    recordedVideo.play();
  });
  
  downloadBtn.addEventListener("click", () => {
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

    // 画面キャプチャ
    // Options for getDisplayMedia()
    var displayMediaOptions = {
        video: {
            cursor: "always"
        },
        audio: true
    };

  const streamButton = document.getElementById("stream");
  let canvasStream = null;

  // キャンバス出力
  streamButton.addEventListener("click", () => {
    getDeviceList();
    recordBtn.disabled = false;
    // カメラ
    navigator.mediaDevices
      .getUserMedia({video: true})
      .then(stream => {
        localVideo.srcObject = stream;
        drawCanvasFromVideo()
      })
      .catch(e => alert("error" + e.message));

    // 画面キャプチャ
    navigator.mediaDevices
      .getDisplayMedia(displayMediaOptions)
      .then(stream => {
        videoElem.srcObject = stream;
        drawCanvasFromVideo()
      })
      .catch(e => alert("error" + e.message));
  });
  
  
  function drawCanvasFromVideo()  {
    const canvas = document.getElementById("canvas");
    const ctx = canvas.getContext('2d');
    setInterval(() => {
      if (canvas && ctx){
          ctx.drawImage(videoElem, 0, 0, canvas.width, canvas.height);
          ctx.drawImage(localVideo, 0, 0, 640, 480, 10, 10, 160, 120);
      };
      // キャプチャを選択しない、または共有を停止した際カメラを全画面表示に切替
      if (videoElem.srcObject == null || videoElem.networkState == 1){
          ctx.drawImage(localVideo, 0, 0, canvas.width, canvas.height);
      };
    }, 1000/30);
    // 以下ストリーム
    canvasStream = canvas.captureStream(30);
    const videoCanvas = document.getElementById("player-canvas");
    videoCanvas.srcObject = canvasStream;
  }

  //デバイスの取得
  var micList = document.getElementById("mic_list");
  var cameraList = document.getElementById("camera_list");

  function clearDeviceList() {
    while(micList.lastChild) {
    micList.removeChild(micList.lastChild);
    }
    while(cameraList.lastChild) {
    cameraList.removeChild(cameraList.lastChild);
    }
  }

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

  function getSelectedVideo() {
    var id = cameraList.options[cameraList.selectedIndex].value;
    return id;
  }

  function getSelectedAudio() {
    var id = micList.options[micList.selectedIndex].value;
    return id;
  }

  // 選択したデバイスの反映
  const startVideoBtn = document.getElementById("start_video_button");
  
  startVideoBtn.addEventListener("click", () => {
    startSelectedVideoAudio();
  });

  function startSelectedVideoAudio() {
    var audioId = getSelectedAudio();
    var deviceId = getSelectedVideo();
    console.log('selected video device id=' + deviceId + ' ,  audio=' + audioId);
    var constraints = {
      audio: {
      deviceId: audioId
      },
      video: { 
      deviceId: deviceId
      }
    };
    console.log('mediaDevice.getMedia() constraints:', constraints);
  
    navigator.mediaDevices.getUserMedia(
    constraints
    ).then(function(stream) {
      localVideo.srcObject = stream;
      drawCanvasFromVideo()
    }).catch(function(err){
    console.error('getUserMedia Err:', err);
    });
  }

  navigator.mediaDevices.ondevicechange = function (evt) {
    console.log('mediaDevices.ondevicechange() evt:', evt);
  };


  // 音声
  const audioPlayer = document.getElementById("player");
  const volumeSlider = document.getElementById("volume");
  
  let audioContext = null;
  let source = null;
  let audioDestination = null;
  let gainNode = null;
  
  streamButton.addEventListener("click", () => {
   navigator.mediaDevices
    .getUserMedia({ audio: true })
    .then(stream => {
      audioContext = new (window.AudioContext || window.webkitAudioContext)();
      source = audioContext.createMediaStreamSource(stream);
      audioDestination = audioContext.createMediaStreamDestination();
      gainNode = audioContext.createGain();
      source.connect(gainNode);
      gainNode.connect(audioDestination);
      gainNode.gain.setValueAtTime(0.5, audioContext.currentTime);
      audioPlayer.srcObject = audioDestination.stream;
    })
    .catch(e => alert("error" + e.message));
  });

  volumeSlider.addEventListener("change", e => {
    const volume = e.target.value;
    gainNode.gain.setValueAtTime(volume / 100, audioContext.currentTime);
    console.log("gain:", gainNode.gain.value);
  });

});