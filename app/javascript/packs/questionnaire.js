document.addEventListener('turbolinks:load', function() {
  const addQuestionButton = document.getElementById('add-question');
  const form = document.getElementById('dynamic-form');
  const formTitle = document.getElementById('form-title');
  const viewerInfo = document.getElementById('viewer-info');
  const errorMessages = document.getElementById('error-messages');
  
  const preVideoQuestionsContainer = document.getElementById('pre-video-questions-container');
  const postVideoQuestionsContainer = document.getElementById('post-video-questions-container');
  const preVideoToggle = document.getElementById('pre-video-toggle');
  const postVideoToggle = document.getElementById('post-video-toggle');
  
  let currentQuestionnaireType = 'pre_video';

  if (preVideoToggle) {
    preVideoToggle.addEventListener('click', function() {
      toggleQuestionnaire('pre_video');
    });
  }

  if (postVideoToggle) {
    postVideoToggle.addEventListener('click', function() {
      toggleQuestionnaire('post_video');
    });
  }
  
  function toggleQuestionnaire(type) {
    if (type === 'pre_video') {
      preVideoQuestionsContainer.style.display = 'block';
      postVideoQuestionsContainer.style.display = 'none';
      formTitle.innerText = 'アンケート作成（動画視聴前）';
      preVideoToggle.classList.add('active');
      postVideoToggle.classList.remove('active');
      viewerInfo.style.display = 'block';
    } else {
      preVideoQuestionsContainer.style.display = 'none';
      postVideoQuestionsContainer.style.display = 'block';
      formTitle.innerText = 'アンケート作成（動画視聴後）';
      preVideoToggle.classList.remove('active');
      postVideoToggle.classList.add('active');
      viewerInfo.style.display = 'none';
    }
    currentQuestionnaireType = type;
  }

  function addQuestion() {
    const template = document.getElementById('question-template').cloneNode(true);
    template.style.display = 'block';
    template.removeAttribute('id');

    if (currentQuestionnaireType === 'pre_video') {
      preVideoQuestionsContainer.appendChild(template);
    } else {
      postVideoQuestionsContainer.appendChild(template);
    }

    const selectElement = template.querySelector('.question-type');
    selectElement.addEventListener('change', function() {
      updateQuestionContent(this);
    });

    template.querySelector('.remove-question').addEventListener('click', function() {
      template.remove();
    });

    template.querySelector('.add-option').addEventListener('click', function() {
      const input = template.querySelector('.new-option-text');
      if (input.value) {
        const selectType = template.querySelector('.question-type').value;
        addOptionToQuestion(selectType, input.value, template);
        input.value = '';
      }
    });

    template.querySelector('.reset-options').addEventListener('click', function() {
      resetOptions(selectElement);
    });

    updateQuestionContent(selectElement);
  }

  function updateQuestionContent(select) {
    const questionField = select.closest('.question-field');
    const questionContent = questionField.querySelector('.question-content');
    const type = select.value;
    const optionsManagement = questionField.querySelector('.options-management');
    optionsManagement.style.display = (type === 'text') ? 'none' : 'block';

    questionContent.querySelectorAll('div').forEach(div => {
      div.style.display = 'none';
      if (div.classList.contains(`${type}-template`)) {
        div.style.display = 'block';
      }
    });

    const resetButton = questionField.querySelector('.reset-options');
    resetButton.style.display = (type === 'dropdown') ? 'inline-block' : 'none';
  }

  function addOptionToQuestion(type, optionText, parentQuestion) {
    const optionContainer = parentQuestion.querySelector(`.${type}-template`);
    if (type === 'dropdown') {
      const select = optionContainer.querySelector('select');
      const option = document.createElement('option');
      option.value = optionText;
      option.textContent = optionText;
      select.appendChild(option);
    } else if (type === 'radio' || type === 'checkbox') {
      const label = document.createElement('label');
      label.className = 'option-item';
      label.innerHTML = `<input type="${type}" name="questions[][answers][]" value="${optionText}"> ${optionText}
      <span class="delete-option" style="cursor:pointer; margin-left: 8px;">&#10060;</span>`;
      optionContainer.appendChild(label);

      label.querySelector('.delete-option').addEventListener('click', function() {
        label.remove();
      });
    }
  }

  function resetOptions(selectElement) {
    const parentQuestion = selectElement.closest('.question-field');
    const optionContainer = parentQuestion.querySelector('.dropdown-template select');
    if (optionContainer) {
      optionContainer.innerHTML = `<option disabled selected>ここから選択してください</option>`;
    }
  }

  form.addEventListener('submit', function(e) {
    e.preventDefault();
    errorMessages.innerHTML = ''; // エラーメッセージをクリア
    const formData = new FormData(form);

    let preVideoQuestionsData = [];
    let postVideoQuestionsData = [];

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
      } else if (questionType === 'radio') {
        const answerInputs = field.querySelectorAll(`input[type="${questionType}"]:checked`);
        answerInputs.forEach(input => {
          if (input.value && input.value.trim() !== '') {
            answers.push(input.value);
          }
        });
      } else if (questionType === 'checkbox') {
        const answerInputs = field.querySelectorAll(`input[type="${questionType}"]:checked`);
        answerInputs.forEach(input => {
          if (input.value && input.value.trim() !== '') {
            answers.push([input.value]);
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

  // イベントリスナーの重複を防ぐ
  if (addQuestionButton && !addQuestionButton.hasAttribute('data-event-added')) {
    addQuestionButton.addEventListener('click', function() {
      addQuestion();
    });
    addQuestionButton.setAttribute('data-event-added', 'true');
  }

  function addQuestion() {
    const template = document.getElementById('question-template').cloneNode(true);
    template.style.display = 'block';
    template.removeAttribute('id');

    if (currentQuestionnaireType === 'pre_video') {
      preVideoQuestionsContainer.appendChild(template);
    } else {
      postVideoQuestionsContainer.appendChild(template);
    }

    const selectElement = template.querySelector('.question-type');
    selectElement.addEventListener('change', function() {
      updateQuestionContent(this);
    });

    template.querySelector('.remove-question').addEventListener('click', function() {
      template.remove();
    });

    template.querySelector('.add-option').addEventListener('click', function() {
      const input = template.querySelector('.new-option-text');
      if (input.value) {
        const selectType = template.querySelector('.question-type').value;
        addOptionToQuestion(selectType, input.value, template);
        input.value = '';
      }
    });

    template.querySelector('.reset-options').addEventListener('click', function() {
      resetOptions(selectElement);
    });

    updateQuestionContent(selectElement);
  }

  // 非同期ページネーションの追加
  $(document).on('click', '.pagination a', function(event) {
    event.preventDefault();
    $.getScript(this.href);
  });

  document.addEventListener("turbolinks:before-cache", function() {
    // 特定の要素やイベントリスナーをリセットする
    $(document).off('click', '.pagination a');
  });
});
