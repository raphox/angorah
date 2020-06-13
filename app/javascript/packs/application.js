// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

handdlerHearts = function handdlerHearts() {
  var els = document.querySelectorAll('.btn-invite');

  for (const el of els) {
    el.addEventListener('click', function (event) {
      event.preventDefault();

      el.classList.toggle('is-active');
      // TOOD: Use ajax
      setTimeout(function() { document.location.href = el.href }, 450);
    });
  }
}


document.addEventListener("DOMContentLoaded", function() {
  handdlerHearts();
});

document.addEventListener("turbolinks:load", function() {
  handdlerHearts();
});
