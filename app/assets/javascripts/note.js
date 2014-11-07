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
    ctx.moveTo(x,y);
    var img='<img src="/assets/note-basic.png" />';
    ctx.drawImage(img,10,10);
  }
}