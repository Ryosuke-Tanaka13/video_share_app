// app/javascript/packs/organizations.js

// Load jQuery before anything else
const $ = require("jquery");
window.$ = $;
window.jQuery = $;

require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
require("channels");
require('admin-lte');

import 'bootstrap';
import '../stylesheets/organizations'; // This file will contain your custom CSS
// import '../stylesheets/uses/main.scss';
import "@fortawesome/fontawesome-free/js/all";

// ツールチップの初期化コードをコメントアウトまたは削除
// document.addEventListener("turbolinks:load", () => {
//   $('[data-toggle="tooltip"]').tooltip()
// });

document.addEventListener("turbolinks:load", () => {
  function controlSubmit() {
    var agreeTermsCheckbox = document.getElementById("agreeTerms");
    var submitButton = document.querySelector("[type='submit']");
    if (agreeTermsCheckbox && submitButton) {
      submitButton.disabled = !agreeTermsCheckbox.checked;

      // チェックボックスの状態変更を監視し、変更があった場合にボタンの状態を更新
      agreeTermsCheckbox.addEventListener('change', function() {
        submitButton.disabled = !this.checked;
      });
    }
  }

  controlSubmit();
});
