$(document).ready(function() {
  $("#learn-play-btn").click(function(e) {
    e.stopImmediatePropagation();
    var id = sequence.id;
    $.post('/learn/'+id+'/start', function(data) {});
  });
});



