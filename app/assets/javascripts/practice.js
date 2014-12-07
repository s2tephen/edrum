$(document).ready(function() {
  var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  var timer;
  var currTime = 0.0;

  function scheduleTick() {
    while(currTime < audioCtx.currentTime + 0.1) {
      playNote(currTime);
      currTime += 60.0 / sequence.bpm;
    }
    timer = window.setTimeout(schedule, 0.1);
  }

  function playTick(t) {
    var oscillator = audioCtx.createOscillator();
    oscillator.connect(audioCtx.destination);
    oscillator.frequency.value = 380;
    oscillator.start(t);
    oscillator.stop(t + 0.05);
  }

  $("#practice-play-btn").click(function(e) {
    var id = sequence.id;
    e.stopImmediatePropagation();
    $.post('/practice/'+id+'/start', function(data) {});
    scheduleTick();
  });
});