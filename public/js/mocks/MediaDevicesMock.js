navigator.mediaDevices.originalGetUserMedia = navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices);

// 自動テスト用のダミーデバイスを取得

function createDummyVideoStream() {
  const canvas = document.createElement('canvas');
  return canvas.captureStream();
}

function createDummyAudioStream() {
  const audioContext = new (window.AudioContext || window.webkitAudioContext)();
  const oscillator = audioContext.createOscillator();
  const dst = oscillator.connect(audioContext.createMediaStreamDestination());
  oscillator.start();
  return dst.stream;
}

function createDummyVideoAndAudioStream() {
  const videoStream = createDummyVideoStream();
  const audioStream = createDummyAudioStream();

  const tracks = [...videoStream.getTracks(), ...audioStream.getTracks()];
  return new MediaStream(tracks);
}


navigator.mediaDevices.getDisplayMedia = function() {
  return new Promise((resolve, reject) => {
    resolve(createDummyVideoAndAudioStream());
  });
};

window.video_user_media = 0;
window.audio_user_media = 0;

navigator.mediaDevices.getUserMedia = function(constraints) {
  return new Promise((resolve, reject) => {
    if (constraints.video && !constraints.video.deviceId) {
      video_user_media++;
      resolve(createDummyVideoStream());
    } else if(constraints.audio && !constraints.audio.deviceId) {
      audio_user_media++;
      resolve(createDummyAudioStream());
    } else if(constraints.video) {
      video_user_media += 2;
      navigator.mediaDevices.originalGetUserMedia(constraints).then(resolve).catch(reject);
    } else if(constraints.audio) {
      audio_user_media += 2;
      navigator.mediaDevices.originalGetUserMedia(constraints).then(resolve).catch(reject);
    } else {
      reject(new Error("No constraints provided"));
    }
  });
};

// ダミーデバイス取得用のメソッド

const videoDevice1 ={
  deviceId: "videoDevice1",
  kind: "videoinput",
  label: "ダミーのビデオデバイス1",
  groupId: "videoGroup1"
};
const videoDevice2 ={
  deviceId: "videoDevice2",
  kind: "videoinput",
  label: "ダミーのビデオデバイス2",
  groupId: "videoGroup1"
};
const audioDevice1 ={
  deviceId: "audioDevice1",
  kind: "audioinput",
  label: "ダミーのオーディオデバイス1",
  groupId: "audioGroup1"
};
const audioDevice2 ={
  deviceId: "audioDevice2",
  kind: "audioinput",
  label: "ダミーのオーディオデバイス2",
  groupId: "audioGroup1"
};
const devices = [videoDevice1,videoDevice2, audioDevice1, audioDevice2];

navigator.mediaDevices.enumerateDevices = function() {
  return new Promise((resolve, reject) => {
    resolve(devices);
  });
};