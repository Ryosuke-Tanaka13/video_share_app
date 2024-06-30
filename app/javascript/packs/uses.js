// app/javascript/packs/use.js

import 'bootstrap';
import '../stylesheets/uses/main.scss';
import "@fortawesome/fontawesome-free/js/all";

document.addEventListener("turbolinks:load", () => {
  $('[data-toggle="tooltip"]').tooltip()
});
