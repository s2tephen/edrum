$(document).ready(function() {
  $("#learn-play-btn").click(function(e) {
    $.post('/learn/5/start', function(data) {
    });
  });
});



