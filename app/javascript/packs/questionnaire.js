document.addEventListener('DOMContentLoaded', function() {
  const preVideoQuestionsContainer = document.getElementById('pre-video-questions-container');
  const postVideoQuestionsContainer = document.getElementById('post-video-questions-container');
  const addQuestionButton = document.getElementById('add-question');
  const form = document.getElementById('dynamic-form');
  const preVideoToggle = document.getElementById('pre-video-toggle');
  const postVideoToggle = document.getElementById('post-video-toggle');
  const viewerInfo = document.querySelector('.viewer-info');
  const formTitle = document.getElementById('form-title');

  let currentQuestionnaireType = 'pre_video';

  function toggleQuestionnaire(type) {
    currentQuestionnaireType = type;
    if (type === 'pre_video') {
      preVideoToggle.classList.add('active');
      postVideoToggle.classList.remove('active');
      preVideoQuestionsContainer.style.display = 'block';
      postVideoQuestionsContainer.style.display = 'none';
      viewerInfo.style.display = 'block';
      formTitle.textContent = 'アンケート作成（動画視聴前）';
      document.getElementById('viewer-name').required = true;
      document.getElementById('viewer-email').required = true;
    } else {
      preVideoToggle.classList.remove('active');
      postVideoToggle.classList.add('active');
      preVideoQuestionsContainer.style.display = 'none';
      postVideoQuestionsContainer.style.display = 'block';
      viewerInfo.style.display = 'none';
      formTitle.textContent = 'アンケート作成（動画視聴後）';
      document.getElementById('viewer-name').required = false;
      document.getElementById('viewer-email').required = false;
    }
  }

  preVideoToggle.addEventListener('click', function() {
    toggleQuestionnaire('pre_video');
  });

  postVideoToggle.addEventListener('click', function() {
    toggleQuestionnaire('post_video');
  });

  addQuestionButton.addEventListener('click', function() {
    const template = document.getElementById('question-template').cloneNode(true);
    template.style.display = 'block';
    template.removeAttribute('id'); // IDを削除して一意性を確保

    if (currentQuestionnaireType === 'pre_video') {
      preVideoQuestionsContainer.appendChild(template);
    } else {
      postVideoQuestionsContainer.appendChild(template);
    }

    const selectElement = template.querySelector('.question-type');
    selectElement.addEventListener('change', function() {
      updateQuestionContent(this);
    });

    // 初期状態の回答形式に応じて内容を設定
    updateQuestionContent(selectElement);
  });

  document.addEventListener('click', function(e) {
    const parentQuestion = e.target.closest('.question');
    if (e.target.classList.contains('add-option')) {
      const input = parentQuestion.querySelector('.new-option-text');
      if (input.value) {
        const selectType = parentQuestion.querySelector('.question-type').value;
        addOptionToQuestion(selectType, input.value, parentQuestion);
        input.value = '';
      }
    } else if (e.target.classList.contains('delete-option')) {
      e.target.closest('label').remove(); // Ensure we are correctly removing the label element
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
    const formData = new FormData(this);
    formData.append('questionnaire_type', currentQuestionnaireType); // アンケートの種類を追加

    fetch('/questionnaires', {
      method: 'POST',
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

  // 初期設定
  toggleQuestionnaire(currentQuestionnaireType);
});
