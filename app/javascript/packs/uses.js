
import 'bootstrap';

import '../stylesheets/uses/main.scss';

import "@fortawesome/fontawesome-free/js/all";

document.addEventListener("turbolinks:load", () => {
  $('[data-toggle="tooltip"]').tooltip()
});


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

document.addEventListener('DOMContentLoaded', function() {
  function controlSubmit() {
    var agreeTermsCheckbox = document.getElementById("agreeTerms");
    var submitButton = document.querySelector("[type='submit']");
    submitButton.disabled = !agreeTermsCheckbox.checked;
  }

  controlSubmit();

  // チェックボックスの状態変更を監視し、変更があった場合にボタンの状態を更新
  document.getElementById("agreeTerms").addEventListener('change', controlSubmit);
});
