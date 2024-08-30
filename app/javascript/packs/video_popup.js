document.addEventListener("turbolinks:load", function() {
  let firstPlay = true; 
  const currentPath = window.location.pathname;

  // videos/new ページでは popup.js のコードを実行しない
  if (currentPath === '/videos/new') {
    return;
  }

  const localVideoPlayer = document.getElementById('mv');

  // URLパラメータをチェック
  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.has('answered') && urlParams.get('answered') === 'true') {
    firstPlay = false; // answeredパラメータが存在する場合に firstPlay を false に設定
  }

  // 動画が再生される直前に発火
  if (localVideoPlayer) {
    localVideoPlayer.addEventListener('play', function() {
      const hiddenLink = document.getElementById('hiddenPopupBeforeLink');
      if (firstPlay && hiddenLink) {
        hiddenLink.click();
        localVideoPlayer.pause(); // 動画を停止
      }
    });

    // 動画を見終わると発火
    localVideoPlayer.addEventListener('ended', function() {
      const hiddenLink = document.getElementById('hiddenPopupAfterLink');
      if (hiddenLink) {
        hiddenLink.click();
      }
    });
  }

  document.querySelectorAll('form[data-remote="true"]').forEach((form) => {
    // コメントフォームを無視
    if (form.id.startsWith('comment-form')) {
      return;
    }

    form.addEventListener('ajax:success', (event) => {
      const [data, status, xhr] = event.detail;
      const message = data.message || '回答が送信されました';
      alert(message);

      // 動画の再生ボタンを有効化し、動画を再生
      const localVideoPlayer = document.getElementById('mv');
      if (localVideoPlayer) {
        firstPlay = false; // 回答が送信された後に firstPlay を false に設定
        localVideoPlayer.removeAttribute('disabled');
        localVideoPlayer.play();
      }

      // モーダルを閉じる
      form.closest('.modal').querySelector('.btn-close').click();
    });

    form.addEventListener('ajax:error', (event) => {
      const [data, status, xhr] = event.detail;
      const message = data.error || '回答の送信に失敗しました';
      alert(message);
    });

    form.addEventListener('submit', function(e) {
      e.preventDefault();
      const errorMessages = form.querySelector('.error-messages');
      if (errorMessages) errorMessages.innerHTML = ''; // エラーメッセージをクリア
      const formData = new FormData(form);

      let preVideoQuestionsData = [];
      let postVideoQuestionsData = [];

      const preVideoQuestionsContainer = document.getElementById('pre-video-questions-container');
      if (preVideoQuestionsContainer) {
        preVideoQuestionsContainer.querySelectorAll('.question-field').forEach(field => {
          const questionText = field.querySelector('.question-input').value;
          const questionType = field.querySelector('.question-type').value;
          let answers = [];

          if (questionType === 'dropdown') {
            const selectElement = field.querySelector('.dropdown-template select');
            selectElement.querySelectorAll('option').forEach(option => {
              if (option.value && option.value.trim() !== '' && option.value !== 'ここから選択してください') {
                answers.push(option.value);
              }
            });
          } else if (questionType === 'radio' || questionType === 'checkbox') {
            const answerInputs = field.querySelectorAll(`input[type="${questionType}"]`);
            answerInputs.forEach(input => {
              if (input.value && input.value.trim() !== '') {
                answers.push(input.value);
              }
            });
          } else if (questionType === 'text') {
            const answer = field.querySelector('.text-template textarea').value;
            if (answer && answer.trim() !== '') {
              answers.push(answer);
            }
          }

          preVideoQuestionsData.push({
            text: questionText,
            type: questionType,
            answers: answers
          });
        });
      }

      const postVideoQuestionsContainer = document.getElementById('post-video-questions-container');
      if (postVideoQuestionsContainer) {
        postVideoQuestionsContainer.querySelectorAll('.question-field').forEach(field => {
          const questionText = field.querySelector('.question-input').value;
          const questionType = field.querySelector('.question-type').value;
          let answers = [];

          if (questionType === 'dropdown') {
            const selectElement = field.querySelector('.dropdown-template select');
            selectElement.querySelectorAll('option').forEach(option => {
              if (option.value && option.value.trim() !== '' && option.value !== 'ここから選択してください') {
                answers.push(option.value);
              }
            });
          } else if (questionType === 'radio' || questionType === 'checkbox') {
            const answerInputs = field.querySelectorAll(`input[type="${questionType}"]`);
            answerInputs.forEach(input => {
              if (input.value && input.value.trim() !== '') {
                answers.push(input.value);
              }
            });
          } else if (questionType === 'text') {
            const answer = field.querySelector('.text-template textarea').value;
            if (answer && answer.trim() !== '') {
              answers.push(answer);
            }
          }

          postVideoQuestionsData.push({
            text: questionText,
            type: questionType,
            answers: answers
          });
        });
      }

      formData.append('questionnaire[pre_video_questionnaire]', JSON.stringify(preVideoQuestionsData));
      formData.append('questionnaire[post_video_questionnaire]', JSON.stringify(postVideoQuestionsData));

      // 追加のパラメータをformDataに追加
      const urlParams = new URLSearchParams(window.location.search);
      formData.append('apply', urlParams.get('apply'));
      formData.append('type', urlParams.get('type'));
      formData.append('popup_before_video', urlParams.get('popup_before_video'));
      formData.append('popup_after_video', urlParams.get('popup_after_video'));

      fetch(form.action, {
        method: form.method,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
          'Accept': 'application/json'
        },
        body: formData
      })
      .then(response => {
        const contentType = response.headers.get('content-type');
        if (!response.ok) {
          return response.text().then(text => Promise.reject(new Error(text)));
        } else if (contentType && contentType.includes('application/json')) {
          return response.json();
        } else {
          return response.text().then(text => Promise.reject(new Error('Unexpected response format')));
        }
      })
      .then(data => {
        if (data.redirect) {
          window.location.href = data.redirect;
        } else if (data.errors) {
          data.errors.forEach(error => {
            const errorItem = document.createElement('p');
            errorItem.textContent = error;
            errorMessages.appendChild(errorItem);
          });
        }
      })
      .catch(error => {
        console.error('Error:', error);
        const errorItem = document.createElement('p');
        errorItem.textContent = 'An unexpected error occurred.';
        errorMessages.appendChild(errorItem);
      });
    });
  });
});
