// app/javascript/packs/viewer.js

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require('admin-lte');
require("jquery");
require("./viewers/auth");

import 'bootstrap';
import '../stylesheets/viewers';
import "@fortawesome/fontawesome-free/js/all";

document.addEventListener("turbolinks:load", () => {
  $('[data-toggle="tooltip"]').tooltip();

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
