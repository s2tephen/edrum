$(document).ready(function() {
  var tick = document.getElementsByTagName("audio")[0];
  tick.addEventListener('ended', function() {
    tick.currentTime = 0;
    setTimeout(function() { tick.play(); }, 60000/sequence.bpm);
  });

  $("#practice-play-btn").click(function(e) {
    var id = sequence.id;
    $.post('/practice/'+id+'/start', function(data) {});
    tick.play();
  });
});



