$(document).ready(function() {
  $('#bpmInput').val(sequence.bpm);

  var songSettings = {
    'bpm': 120,
    'metronome': true,
    'loop': false,
    'stepByStep': false,
    'sticking': false,
    'demoMode': false
  };

  var audioContext = new AudioContext();
  var isPlaying = false;
  var startTime;
  var current16thNote;

  var lookahead = 25.0;
  var scheduleAheadTime = 0.1;
  var nextNoteTime = 0.0;
  var noteResolution = 2;
  var noteLength = 0.075;
  var notesInQueue = [];
  var seqIn16thNotes = [];
  var timerWorker = new Worker("../assets/metronomeworker.js");

  for (i = 0; i < sequence.bars * sequence.meter_bottom * (16/sequence.meter_bottom); i++) {
    var tick = [];
    while (seqNotes.length > 0 && (seqNotes[0].bar * sequence.meter_bottom + seqNotes[0].beat) * (16/sequence.meter_bottom) == i) {
      tick.push(seqNotes.shift().drum);
    }
    seqIn16thNotes.push(tick);
  }

  timerWorker.onmessage = function(e) {
    if (e.data == "tick") {
      scheduler();
    }
    else
      console.log("message: " + e.data);
  };
  timerWorker.postMessage({"interval":lookahead});

  var hitSource = new EventSource("/serial");
  hitSource.onmessage = function(e) {
    var hit = jQuery.parseJSON (e.data);
    if (hit[2] == 1 && seqIn16thNotes[current16thNote].includes(hit[0])) { // exact note
      console.log('good');
      console.log('diff: ' + (hit[1] - notesInQueue[current16thNote].time));
    }
  };

  // advance current note and time by a 16th note
  function nextNote() {
    var secondsPerBeat = 60.0 / songSettings.bpm;
    nextNoteTime += 0.25 * secondsPerBeat;
    current16thNote++;
  }

  // push note onto the queue
  function scheduleNote(beatNumber, time) {
    if (beatNumber == (2 + sequence.bars) * sequence.meter_bottom * (16/sequence.meter_bottom))
      return; // don't play the last note in a sequence
    if (beatNumber == -28 || beatNumber == -20) // count in - audio only TODO: visuals
      return;
    if ((noteResolution == 1) && (beatNumber % 2))
      return; // don't play 16th notes
    if ((noteResolution == 2) && (beatNumber % 4))
      return; // don't play 8th notes

    if (beatNumber > -1)
      notesInQueue.push({ note: beatNumber, time: time });

    // create an oscillator
    var osc = audioContext.createOscillator();
    osc.connect(audioContext.destination);
    osc.frequency.value = 500;
    osc.start(time);
    osc.stop(time + noteLength);
  }

  // schedule notes and advance pointer
  function scheduler() {
    while (nextNoteTime < audioContext.currentTime + scheduleAheadTime) {
      scheduleNote(current16thNote, nextNoteTime);
      nextNote();
    }
  }

  // toggle play/stop
  function play() {
    isPlaying = !isPlaying;
    swapButton();
    if (isPlaying) { // start playing
      animateLine(-1);
      current16thNote = -32 * sequence.meter_top/sequence.meter_bottom;
      nextNoteTime = audioContext.currentTime;
      timerWorker.postMessage("start");
      return "stop";
    }
    else {
      animateLine(0);
      timerWorker.postMessage("stop");
      return "play";
    }
  }

  // swap play/stop buttons
  function swapButton() {
    if (isPlaying) {
      $('.play-btn').removeClass('play-btn').addClass('stop-btn').children().first().removeClass('fa-play').addClass('fa-stop');
      $('.song-info').addClass('playing');
      $('.song-settings').addClass('playing');
    }
    else {
      $('.stop-btn').removeClass('stop-btn').addClass('play-btn').children().first().removeClass('fa-stop').addClass('fa-play');
      $('.song-info').removeClass('playing');
      $('.song-settings').stop(true, false).css('border-left-width', '0').removeClass('playing');
    }
  }

  function animateLine(lineNum) {
    if (isPlaying) {
      if (lineNum == -1) {
        setTimeout(function() { animateLine(0); }, 120000 * sequence.meter_bottom / songSettings.bpm);
      }
      else if (lineNum == 0) {
        $('.song-settings').animate({ borderLeftWidth: '1440px' }, 60000 * sequence.bars * sequence.meter_bottom / songSettings.bpm , 'linear');
        if (sequence.bars != 2) {
          $('.marker-current').animate({
            width: '700px'
          }, 60000 / songSettings.bpm * sequence.meter_bottom, 'linear', function() {
            $(this).animate({
              width: '1400px'
            }, 60000 / songSettings.bpm * sequence.meter_bottom, 'linear', function() { animateLine(lineNum + 1); });
          });
        }
        else {
          $('.marker-current').animate({
            width: '1400px'
          }, 60000 / songSettings.bpm * sequence.meter_bottom, 'linear', function() {
            lineNum += 1;
            $('.main').animate({ scrollTop: 360*lineNum + 'px' }, 120000 / songSettings.bpm * sequence.meter_bottom, 'linear');
            $('.marker-current').removeClass('marker-current');
            $('.wrapper').append('<div class="marker marker-current" style="top: ' + (235 + 360*lineNum) + 'px"></div>');
            $('.marker-current').animate({
              width: '1400px'
            }, 60000 / songSettings.bpm * sequence.meter_bottom, 'linear', function() { animateLine(1); });
          });
        }
      }
      else if (lineNum == Math.floor(sequence.bars / 2 + 0.5)) { // end song
        if (songSettings.loop) {
          $('.main').scrollTop(0);
          $('.marker').remove();
          animateLine(0);
          current16thNote = -32 * sequence.meter_top/sequence.meter_bottom;
          currentTime = 0;
        }
        else {
          $('.main').animate({
            scrollTop: '0px'
          }, function() {
            $('.marker').remove();
          });
          play();
        }
      }
      else {
        // instantaneous change
        // $('.main').scrollTop(360*lineNum);

        // end of line transition
        // $('.main').animate({ scrollTop: 360*lineNum + 'px' }, (10000 / songSettings.bpm) * sequence.meter_bottom, 'linear');

        // constant scroll
        $('.main').animate({ scrollTop: 360*lineNum + 'px' }, 120000 / songSettings.bpm * sequence.meter_bottom, 'linear');

        $('.marker-current').removeClass('marker-current');
        $('.wrapper').append('<div class="marker marker-current" style="top: ' + (235 + 360*lineNum) + 'px"></div>');
        $('.marker-current').animate({
          width: '1400px'
        }, 120000 / songSettings.bpm * sequence.meter_bottom, 'linear', function() { animateLine(lineNum + 1); });
      }
    }
    else {
      $('.marker').stop(true, false).remove();
      $('.main').stop(true, false).animate({ scrollTop: 0 });
    }
  }

  // button event handler
  $(".play-btn, .listen-btn").click(function(e) {
    e.stopImmediatePropagation();

    // update songSettings
    songSettings = {
      'bpm': $('#bpmInput').val(),
      'metronome': $('#enableMetronome').is(':checked'),
      'loop': $('#enableLoop').is(':checked'),
      'stepByStep': $('#enableStepByStep').is(':checked'),
      'sticking': $('#enableSticking').is(':checked'),
      'demoMode': $(this).hasClass('listen-btn')
    };

    $.ajax({
      type : "POST",
      url :  '/practice/' + sequence.id + '/start',
      dataType: 'json',
      contentType: 'application/json',
      data : JSON.stringify({
        demoMode: songSettings.demoMode,
        playBPM: songSettings.bpm,
        enableLoop: songSettings.loop,
        enableStepByStep: songSettings.stepByStep,
        enableSticking: songSettings.sticking
      })
    });

    play();
  });
});