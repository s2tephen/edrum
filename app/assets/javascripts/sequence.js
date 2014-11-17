// this file will contain the representation of a sequence
// must be able to draw itself by calling all Notes within it

var Sequence = function(notes, sequenceObj) {
    ////////////////////////////////////////////////
    // Representation
    //

  this.notes = notes;
  this.sequenceObj = sequenceObj;

  this.meter_top = 4/*sequenceObj.meter_top*/;
  this.id = sequenceObj.id;


  ////////////////////////////////////////////////
  // Public methods
  //

  this.draw = function(ctx, cur_bar, cur_beat) {
    // TODO convert to draw based on bar/beat instead of cur location
    for (var i = 0; i < this.notes.length; i++) {
      var y_loc;
      switch(this.notes[i].drum) {
        case 0:
          y_loc = -1;
          break;
        case 1:
          y_loc = 0;
          break;
        case 2:
          y_loc = .5;
          break;
        case 3:
          y_loc = 1;
          break;
        case 4:
          y_loc = 1.5;
          break;
        case 5:
          y_loc = 2;
          break;
        case 6:
          y_loc = 3;
          break;
        case 7:
          y_loc = 4;
          break;
      }
      y_loc = TOP_OFFSET + (y_loc*LINE_SPREAD);

      var x_loc;
      var should_draw = true;
      if (cur_bar > this.notes[i].bar) {
        should_draw = false;
      } else {
        if (cur_bar == this.notes[i].bar && cur_beat > this.notes[i].beat) {
          should_draw = false;
        } else {
          var bar_offset = (this.notes[i].bar - cur_bar) * this.meter_top;
          var beat_offset = this.notes[i].beat - cur_beat;
          x_loc = (bar_offset + beat_offset) * LINE_SPREAD*WIDTH_MULTIPLIER + LINE_SPREAD*5;
        }
      }
      if (should_draw) {
        this.notes[i].draw(ctx,
                      x_loc,
                      y_loc,
                      LINE_SPREAD,
                      LINE_SPREAD*WIDTH_MULTIPLIER - NOTE_SPACING);
      }
    }
  }



  // this.flatten = function(meter_top, meter_bottom) {
  //   //  3/4 = 3 quarter notes per bar
  //   //  4/4 = 4 quarter notes per bar

  //   this.flatNotes = [];
  //   for (var i = 0; i < this.notes.length; i++) {
  //     this.flatNotes.append()
  //   }
  // }
}