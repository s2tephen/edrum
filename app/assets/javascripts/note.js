// this file will contain the representation of a note
// will have a draw method

var Note = function(noteObj) {
  ////////////////////////////////////////////////
  // Representation
  //
  this.noteObj = noteObj;

  this.drum = noteObj.drum;
  this.duration = noteObj.duration;

  this.bar = noteObj.bar;
  this.beat = noteObj.beat;

  ////////////////////////////////////////////////
  // Public methods
  //

  this.draw = function(ctx, x, y, height, width) {
    var imageObj = new Image();

    imageObj.onload = function() {
      ctx.drawImage(imageObj, x, y, width, height);
    };

    // code in different note images based on this.drum
    imageObj.src = '/assets/oval-basic.png';
  }
}