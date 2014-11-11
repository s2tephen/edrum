// this file will contain the representation of a note
// will have a draw method

var Note = function(note, duration) {
    ////////////////////////////////////////////////
    // Representation
    //

  this.note = note;
  this.duration = duration;

  ////////////////////////////////////////////////
  // Public methods
  //

  this.draw = function(ctx, x, y, height, width){
    var imageObj = new Image();

    imageObj.onload = function() {
      ctx.drawImage(imageObj, x, y, width, height);
    };
    imageObj.src = '/assets/note-basic.png';
  }
}