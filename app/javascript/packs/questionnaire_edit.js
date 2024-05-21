document.addEventListener("turbolinks:load", function() {
  const preVideoQuestionsContainer = document.getElementById('pre-video-questions-container');
  const postVideoQuestionsContainer = document.getElementById('post-video-questions-container');

  const preVideoQuestionsData = JSON.parse(document.getElementById('pre_video_questionnaire').value || '[]');
  const postVideoQuestionsData = JSON.parse(document.getElementById('post_video_questionnaire').value || '[]');

  function clearQuestions(container) {
    while (container.firstChild) {
      container.removeChild(container.firstChild);
    }
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

  function populateQuestions(container, questionsData) {
    clearQuestions(container);

    questionsData.forEach(question => {
      const template = document.getElementById('question-template').cloneNode(true);
      template.style.display = 'block';
      template.removeAttribute('id');

      template.querySelector('.question-input').value = question.text;
      const selectElement = template.querySelector('.question-type');
      selectElement.value = question.type;
      updateQuestionContent(selectElement);

      if (question.type === 'dropdown') {
        const selectContainer = template.querySelector('.dropdown-template select');
        question.answers.forEach(answer => {
          const option = document.createElement('option');
          option.value = answer;
          option.textContent = answer;
          selectContainer.appendChild(option);
        });
      } else if (question.type === 'radio' || question.type === 'checkbox') {
        const optionContainer = template.querySelector(`.${question.type}-template`);
        question.answers.forEach(answer => {
          const label = document.createElement('label');
          label.className = 'option-item';
          label.innerHTML = `<input type="${question.type}" name="questions[][answers][]" value="${answer}"> ${answer}
          <span class="delete-option" style="cursor:pointer; margin-left: 8px;">&#10060;</span>`;
          optionContainer.appendChild(label);

          label.querySelector('.delete-option').addEventListener('click', function() {
            label.remove();
          });
        });
      }

      container.appendChild(template);

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
    });
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

  populateQuestions(preVideoQuestionsContainer, preVideoQuestionsData);
  populateQuestions(postVideoQuestionsContainer, postVideoQuestionsData);

  // 新しい質問を追加するイベントリスナー
  const addQuestionButton = document.getElementById('add-question');
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
  });
});
