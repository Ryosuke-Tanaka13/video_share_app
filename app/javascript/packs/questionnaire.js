document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('questions-container');
  const addQuestionButton = document.getElementById('add-question');
  const form = document.getElementById('dynamic-form');

  addQuestionButton.addEventListener('click', function() {
    const template = document.getElementById('question-template').cloneNode(true);
    template.style.display = 'block';
    template.removeAttribute('id'); // IDを削除して一意性を確保
    container.appendChild(template);

    const selectElement = template.querySelector('.question-type');
    selectElement.addEventListener('change', function() {
      updateQuestionContent(this);
    });

    // 初期状態の回答形式に応じて内容を設定
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
});
