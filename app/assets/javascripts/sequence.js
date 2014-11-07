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

  this.draw = function(ctx){
    // TODO
    for each(var note in this.notes) {
      note.draw(ctx, 50, 50, 100,100);
    }
  }
}