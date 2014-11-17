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

  this.hand = noteObj.hand;

  ////////////////////////////////////////////////
  // Public methods
  //

  this.draw = function(ctx, x, y, height, width) {
    // var imageObj = new Image();

    // imageObj.onload = function() {
    //   ctx.drawImage(imageObj, x, y, width, height);
    // };

    // // code in different note images based on this.drum
    // imageObj.src = '/assets/oval-basic.png';


    ctx.beginPath();
    for (var i = 0 * Math.PI; i < 2 * Math.PI; i += 0.01 ) {
        xPos = x + width/2 - (height/2 * Math.sin(i)) * Math.sin(0 * Math.PI) + (width/2 * Math.cos(i)) * Math.cos(0 * Math.PI);
        yPos = y + height/2 + (width/2 * Math.cos(i)) * Math.sin(0 * Math.PI) + (height/2 * Math.sin(i)) * Math.cos(0 * Math.PI);

        if (i == 0) {
            ctx.moveTo(xPos, yPos);
        } else {
            ctx.lineTo(xPos, yPos);
        }
    }
    switch(this.hand) {
      case "right":
        ctx.fillStyle = "red";
        break;
      case "left":
        ctx.fillStyle = "green";
        break;
      case "foot":
        ctx.fillStyle = "blue";
        break;
      default:
        ctx.fillStyle = "black";
    }

    ctx.fill();
    ctx.lineWidth = 2;
    ctx.strokeStyle = "#232323";
    // ctx.closePath();
    ctx.stroke();

    // draw
    ctx.beginPath();
    ctx.strokeStyle = "black";
    if(this.drum == 7) {
      ctx.fillRect(x+width-5,y+0.5*LINE_SPREAD, 6, 3*LINE_SPREAD);
    } else {
      ctx.fillRect(x+width-5,y-2.5*LINE_SPREAD, 6, 3*LINE_SPREAD);
    }
    ctx.stroke();
  }
}