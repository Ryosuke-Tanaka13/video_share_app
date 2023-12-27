$(document).on('turbolinks:load', function() {
  $(function () {
    $('#video-form-reset').click(function() {
      $('#search-title').val("");
      $('#search-open_period_from').val("");
      $('#search-open_period_to').val("");
      $('#search-range-all').val("");
      $('#search-range-true').val("");
      $('#search-range-false').val("");
      $('#search-user-name').val("");
    });
  });
});
