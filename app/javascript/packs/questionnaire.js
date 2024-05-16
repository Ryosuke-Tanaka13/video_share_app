document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('questions-container');
  const addQuestionButton = document.getElementById('add-question');
  const form = document.getElementById('dynamic-form');
  const formTitle = document.getElementById('form-title');

  const preVideoQuestionsContainer = document.getElementById('pre-video-questions-container');
  const postVideoQuestionsContainer = document.getElementById('post-video-questions-container');
  const preVideoToggle = document.getElementById('pre-video-toggle');
  const postVideoToggle = document.getElementById('post-video-toggle');
  
  let currentQuestionnaireType = 'pre_video';

  preVideoToggle.addEventListener('click', function() {
    toggleQuestionnaire('pre_video');
  });

  postVideoToggle.addEventListener('click', function() {
    toggleQuestionnaire('post_video');
  });

  function toggleQuestionnaire(type) {
    if (type === 'pre_video') {
      preVideoQuestionsContainer.style.display = 'block';
      postVideoQuestionsContainer.style.display = 'none';
      formTitle.innerText = 'アンケート作成（動画視聴前）';
      preVideoToggle.classList.add('active');
      postVideoToggle.classList.remove('active');
    } else {
      preVideoQuestionsContainer.style.display = 'none';
      postVideoQuestionsContainer.style.display = 'block';
      formTitle.innerText = 'アンケート作成（動画視聴後）';
      preVideoToggle.classList.remove('active');
      postVideoToggle.classList.add('active');
    }
    currentQuestionnaireType = type;
  }

  addQuestionButton.addEventListener('click', function() {
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

    updateQuestionContent(selectElement);
  });

  container.addEventListener('click', function(e) {
    const parentQuestion = e.target.closest('.question');
    if (e.target.classList.contains('add-option')) {
      const input = parentQuestion.querySelector('.new-option-text');
      if (input.value) {
        const selectType = parentQuestion.querySelector('.question-type').value;
        addOptionToQuestion(selectType, input.value, parentQuestion);
        input.value = '';
      }
    } else if (e.target.classList.contains('delete-option')) {
      e.target.closest('label').remove();
    } else if (e.target.classList.contains('remove-question')) {
      e.target.closest('.question-field').remove();
    } else if (e.target.classList.contains('reset-options')) {
      const selectElement = parentQuestion.querySelector('.question-type');
      resetOptions(selectElement);
    }
  });

  function updateQuestionContent(select) {
    const questionField = select.closest('.question-field');
    const questionContent = questionField.querySelector('.question-content');
    const type = select.value;
    const optionsManagement = questionField.querySelector('.options-management');
    optionsManagement.style.display = (type === 'text') ? 'none' : 'block';

    questionContent.querySelectorAll('div').forEach(div => {
      div.style.display = 'none';
      if (div.className.includes(type + '-template')) {
        div.style.display = 'block';
      }
    });

    const resetButton = questionField.querySelector('.reset-options');
    resetButton.style.display = (type === 'dropdown') ? 'inline-block' : 'none';
  }

  function addOptionToQuestion(type, optionText, parentQuestion) {
    const optionContainer = parentQuestion.querySelector(`.${type}-template`);
    if (type === 'dropdown') {
      let select = optionContainer.querySelector('select');
      if (!select) {
        optionContainer.innerHTML = `<select name="questions[][answer]">
          <option disabled selected>ここから選択してください</option>
        </select>`;
        select = optionContainer.querySelector('select');
      }

      const option = document.createElement('option');
      option.value = optionText;
      option.textContent = optionText;
      select.appendChild(option);
    } else {
      const label = document.createElement('label');
      label.className = 'option-item';
      label.innerHTML = `<input type="${type}" name="questions[][answer]" value="${optionText}"> ${optionText}
      <span class="delete-option" style="cursor:pointer; margin-left: 8px;">&#10060;</span>`;
      optionContainer.appendChild(label);
    }
  }

  function resetOptions(selectElement) {
    const parentQuestion = selectElement.closest('.question');
    const optionContainer = parentQuestion.querySelector('.dropdown-template');
    const select = optionContainer.querySelector('select');
    if (select) {
      select.innerHTML = `<option disabled selected>ここから選択してください</option>`;
    }
  }

  form.addEventListener('submit', function(e) {
    e.preventDefault();
    const formData = new FormData(form);

    let questionsData = [];
    const questionFields = currentQuestionnaireType === 'pre_video'
      ? preVideoQuestionsContainer.querySelectorAll('.question-field')
      : postVideoQuestionsContainer.querySelectorAll('.question-field');

    questionFields.forEach(field => {
      const questionText = field.querySelector('.question-input').value;
      const questionType = field.querySelector('.question-type').value;
      const answerInputs = field.querySelectorAll('input[name="questions[][answer]"], textarea[name="questions[][answer]"]');

      let answers = [];
      answerInputs.forEach(input => {
        answers.push(input.value);
      });

      questionsData.push({
        text: questionText,
        type: questionType,
        answers: answers
      });
    });

    const questionnaireKey = currentQuestionnaireType === 'pre_video' ? 'pre_video_questionnaire' : 'post_video_questionnaire';
    formData.append(`questionnaire[${questionnaireKey}]`, JSON.stringify(questionsData));

    fetch(form.action, {
      method: form.method,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      if (data.redirect) {
        window.location.href = data.redirect;
      }
    })
    .catch(error => console.error('Error:', error));
  });
});
