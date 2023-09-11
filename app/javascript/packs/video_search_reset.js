$(document).on('turbolinks:load', function() {
  $(function () {
    $('#video-form-reset').click(function() {
      $('#search-title').val("");
      $('#search-created_at_from').val("");
      $('#search-created_at_to').val("");
      $('#search-range-all').val("");
      $('#search-range-true').val("");
      $('#search-range-false').val("");
      $('#search-user-name').val("");
    });
  });
});
