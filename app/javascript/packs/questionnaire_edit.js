document.addEventListener("turbolinks:load", function() {
  // 質問を表示するためのコンテナを取得
  const preVideoQuestionsContainer = document.getElementById('pre-video-questions-container');
  const postVideoQuestionsContainer = document.getElementById('post-video-questions-container');

  // 事前に設定されている質問データをJSON形式からオブジェクトに変換して取得
  const preVideoQuestionsData = JSON.parse(document.getElementById('pre_video_questionnaire').value || '[]');
  const postVideoQuestionsData = JSON.parse(document.getElementById('post_video_questionnaire').value || '[]');

  // 質問リストをクリアする関数
  function clearQuestions(container) {
    while (container.firstChild) {
      container.removeChild(container.firstChild);
    }
  }

  // 質問の形式に応じて表示内容を更新する関数
  function updateQuestionContent(select) {
    const questionField = select.closest('.question-field');
    const questionContent = questionField.querySelector('.question-content');
    const type = select.value;
    const optionsManagement = questionField.querySelector('.options-management');
    // テキスト形式の場合、選択肢管理の表示を非表示にする
    optionsManagement.style.display = (type === 'text') ? 'none' : 'block';

    // 選択された質問形式に合わせて表示する要素を切り替える
    questionContent.querySelectorAll('div').forEach(div => {
      div.style.display = 'none';
      if (div.classList.contains(`${type}-template`)) {
        div.style.display = 'block';
      }
    });

    // ドロップダウン形式の場合、リセットボタンを表示する
    const resetButton = questionField.querySelector('.reset-options');
    resetButton.style.display = (type === 'dropdown') ? 'inline-block' : 'none';
  }

  // 質問データを元に質問リストをコンテナに追加する関数
  function populateQuestions(container, questionsData) {
    clearQuestions(container);

    questionsData.forEach(question => {
      const template = document.getElementById('question-template').cloneNode(true);
      template.style.display = 'block';
      template.removeAttribute('id');

      // 質問のテキストと形式を設定
      template.querySelector('.question-input').value = question.text;
      const selectElement = template.querySelector('.question-type');
      selectElement.value = question.type;
      updateQuestionContent(selectElement);

      // 必須チェックボックスの状態を設定
      const requiredCheckbox = template.querySelector('.required-checkbox');
      requiredCheckbox.checked = question.required;

      // 質問形式ごとの選択肢を追加
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

          // オプションの削除ボタンのイベントリスナーを追加
          label.querySelector('.delete-option').addEventListener('click', function() {
            label.remove();
          });
        });
      }

      // 質問をコンテナに追加
      container.appendChild(template);

      // 質問形式の変更イベントリスナーを追加
      selectElement.addEventListener('change', function() {
        updateQuestionContent(this);
      });

      // 質問の削除ボタンのイベントリスナーを追加
      template.querySelector('.remove-question').addEventListener('click', function() {
        template.remove();
      });

      // 新しいオプションの追加ボタンのイベントリスナーを追加
      template.querySelector('.add-option').addEventListener('click', function() {
        const input = template.querySelector('.new-option-text');
        if (input.value) {
          const selectType = template.querySelector('.question-type').value;
          addOptionToQuestion(selectType, input.value, template);
          input.value = '';
        }
      });

      // オプションのリセットボタンのイベントリスナーを追加
      template.querySelector('.reset-options').addEventListener('click', function() {
        resetOptions(selectElement);
      });

      updateQuestionContent(selectElement);
    });
  }

  // 質問にオプションを追加する関数
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

      // オプション削除ボタンのイベントリスナーを追加
      label.querySelector('.delete-option').addEventListener('click', function() {
        label.remove();
      });
    }
  }

  // ドロップダウンのオプションをリセットする関数
  function resetOptions(selectElement) {
    const parentQuestion = selectElement.closest('.question-field');
    const optionContainer = parentQuestion.querySelector('.dropdown-template select');
    if (optionContainer) {
      optionContainer.innerHTML = `<option disabled selected>ここから選択してください</option>`;
    }
  }

  // 質問リストを初期化して表示
  populateQuestions(preVideoQuestionsContainer, preVideoQuestionsData);
  populateQuestions(postVideoQuestionsContainer, postVideoQuestionsData);

  // 新しい質問を追加するボタンのイベントリスナーを追加
  const addQuestionButton = document.getElementById('add-question');
  addQuestionButton.addEventListener('click', function() {
    const template = document.getElementById('question-template').cloneNode(true);
    template.style.display = 'block';
    template.removeAttribute('id');

    // 動画視聴前か後かで質問を追加するコンテナを決定
    if (currentQuestionnaireType === 'pre_video') {
      preVideoQuestionsContainer.appendChild(template);
    } else {
      postVideoQuestionsContainer.appendChild(template);
    }

    const selectElement = template.querySelector('.question-type');
    selectElement.addEventListener('change', function() {
      updateQuestionContent(this);
    });

    // 質問の削除ボタンのイベントリスナーを追加
    template.querySelector('.remove-question').addEventListener('click', function() {
      template.remove();
    });

    // 新しいオプションの追加ボタンのイベントリスナーを追加
    template.querySelector('.add-option').addEventListener('click', function() {
      const input = template.querySelector('.new-option-text');
      if (input.value) {
        const selectType = template.querySelector('.question-type').value;
        addOptionToQuestion(selectType, input.value, template);
        input.value = '';
      }
    });

    // オプションのリセットボタンのイベントリスナーを追加
    template.querySelector('.reset-options').addEventListener('click', function() {
      resetOptions(selectElement);
    });

    updateQuestionContent(selectElement);
  });
});
