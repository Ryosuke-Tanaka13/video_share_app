document.addEventListener('DOMContentLoaded', function() {
  const container = document.getElementById('questions-container');
  const addQuestionButton = document.getElementById('add-question');
  const form = document.getElementById('dynamic-form');  // formを定義していなかったので追加

  // 質問を追加する処理
  addQuestionButton.addEventListener('click', function() {
    const template = document.getElementById('question-template').cloneNode(true);
    template.style.display = 'block';
    template.querySelector('.question-type').addEventListener('change', function() {
      updateQuestionContent(this);
    });
    container.appendChild(template);
  });

  function updateQuestionContent(select) {
    const questionContent = select.parentNode.querySelector('.question-content');
    const type = select.value;
    questionContent.querySelectorAll('div').forEach(div => {
      if (div.className.includes(type + '-template')) {
        div.style.display = 'block';
      } else {
        div.style.display = 'none';
      }
    });
  }

  // 質問の削除機能
  container.addEventListener('click', function(e) {
    if (e.target.classList.contains('remove-question')) {
      e.target.parentNode.remove();
    }
  });

  // フォームデータをサーバーに送信する処理
  form.addEventListener('submit', function(e) {
    e.preventDefault();
    const formData = new FormData(this);
    fetch('/path/to/submit', {
      method: 'POST',
      body: formData
    })
    .then(response => response.json())
    .then(data => console.log(data))
    .catch(error => console.error('Error:', error));
  });
});

