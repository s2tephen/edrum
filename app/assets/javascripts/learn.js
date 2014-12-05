$(document).ready(function() {
  $("#learn-play-btn").click(function(e) {
    alert("clicked play");
    $.post('/learn/5/start', function(data) {
      console.log("yolo");
      alert(data);
    });
  });
});



