// this file will contain the representation of a sequence
// must be able to draw itself by calling all Notes within it

var Sequence = function(notes) {
    ////////////////////////////////////////////////
    // Representation
    //

  this.notes = notes;

  ////////////////////////////////////////////////
  // Public methods
  //

  this.draw = function(ctx, cur_location){
    // TODO
    for (var i = 0; i + cur_location < this.notes.length; i++) {
      notes[i+cur_location].draw(ctx,
                                 0 + (i*LINE_SPREAD),
                                 TOP_OFFSET - LINE_SPREAD + (notes[i+cur_location].note*LINE_SPREAD),
                                 LINE_SPREAD,
                                 LINE_SPREAD);
    }
  }
}