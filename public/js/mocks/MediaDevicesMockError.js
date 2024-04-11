// getDisplayMedia が失敗するようにモック
navigator.mediaDevices.getDisplayMedia = function() {
  return new Promise((resolve, reject) => {
    reject(new Error("getDisplayMedia failure"));
  });
};

// getUserMedia が失敗するようにモック
navigator.mediaDevices.getUserMedia = function(constraints) {
  return new Promise((resolve, reject) => {
    reject(new Error("getUserMedia failure"));
  });
};

navigator.mediaDevices.enumerateDevices = function() {
  return new Promise((resolve, reject) => {
    reject(new Error("getUserMedia failure"));
  });
};
