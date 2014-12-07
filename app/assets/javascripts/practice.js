$(document).ready(function() {
  $('#bpmInput').val(sequence.bpm);

  var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  var timer;
  var currTime = 0.0;
  var isPlaying = false;
  var playBPM = $('#bpmInput').val();

  function scheduleTick() {
    while(currTime < audioCtx.currentTime + 0.1) {
      playTick(currTime);
      currTime += 60.0 / playBPM;
    }
    timer = window.setTimeout(scheduleTick, 0.1);
  }

  function playTick(t) {
    var oscillator = audioCtx.createOscillator();
    oscillator.connect(audioCtx.destination);
    oscillator.frequency.value = 500;
    oscillator.start(t);
    oscillator.stop(t + 0.075);
  }

  function showFeedback(c) {
    if (c == 0) {
      $('.note-feedback').text('bad').css('color', 'rgb(192, 57, 43)');
    }
    else {
      $('.note-feedback').text('good').css('color', 'rgb(39, 174, 96)');
    }
    $('.note-feedback').css('opacity', 1);
    setTimeout(function() { $('.note-feedback').animate({ opacity: 0 }, 100); }, 750);
  }

  $("#practice-play-btn, #practice-listen-btn").click(function(e) {
    e.stopImmediatePropagation();

    if (!isPlaying) {
      var id = sequence.id;
      if ($(this).hasClass('play-btn')) {
        $.post('/practice/'+id+'/start', function(data) {});
      }

      if ($('#enableMetronome').is(':checked'))
        scheduleTick(); 
      
      $('.song-info').addClass('playing');
      $('.song-settings').addClass('playing');
      $('.play-btn i').removeClass('fa-play').addClass('fa-stop');

      $('.marker').remove();
      $('.wrapper').append('<div class="marker marker-current" style="top: 235px; width: 200px;"></div>');
      animateLine(0);
      isPlaying = true;
      $('.song-settings').animate({ borderLeftWidth: '1440px' }, 60000 * sequence.bars * sequence.meter_bottom / playBPM , 'linear');
    }
    else {
      window.clearInterval(timer);
      $('.main').stop(true, false);
      $('.marker-current').stop(true, false);
      $('.song-settings').stop(true, false).css('border-left-width', '0');
      $('.marker').remove();

      $('.main').animate({
        scrollTop: '0px'
      });
      $('.song-info').removeClass('playing');
      $('.song-settings').removeClass('playing');
      $('.play-btn i').removeClass('fa-stop').addClass('fa-play');
      isPlaying = false;
    }
  });

  function animateLine(lineNum) {
    if (lineNum == 0) {
      $('.marker-current').animate({
        width: '700px'
      }, 60000 / playBPM * sequence.meter_bottom, 'linear', function() {
        $(this).animate({
          width: '1400px'
        }, 60000 / playBPM * sequence.meter_bottom, 'linear', function() { animateLine(lineNum + 1); });
      });
    }
    else if (lineNum == Math.floor(sequence.bars / 2 + 0.5)) {
      window.clearInterval(timer);
      $('.main').animate({
        scrollTop: '0px'
      }, function() {
        $('.marker').remove();
      });
      $('.song-info').removeClass('playing');
      $('.song-settings').css('border-left-width', '0').removeClass('playing');
      $('.play-btn i').removeClass('fa-stop').addClass('fa-play');
      isPlaying = false;
      return;
    }
    else {
      // instantaneous change
      // $('.main').scrollTop(360*lineNum);

      // end of line transition
      // $('.main').animate({ scrollTop: 360*lineNum + 'px' }, (10000 / playBPM) * sequence.meter_bottom, 'linear');

      // constant scroll
      $('.main').animate({ scrollTop: 360*lineNum + 'px' }, 120000 / playBPM * sequence.meter_bottom, 'linear');

      $('.marker-current').removeClass('marker-current');
      $('.wrapper').append('<div class="marker marker-current" style="top: ' + (235 + 360*lineNum) + 'px"></div>');
      $('.marker-current').animate({
        width: '1400px'
      }, 120000 / playBPM * sequence.meter_bottom, 'linear', function() { animateLine(lineNum + 1); });
    }
  }
});