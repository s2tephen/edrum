// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require_tree .

$(document).ready(function() {
  $('.navbar-menu').click(function() {
    $('body').toggleClass('menu-visible');
  });
  $('.main').click(function() {
    $('body').removeClass('menu-visible');
  });
  $('.navbar-search').click(function() {
    $('body').toggleClass('search-visible');
  });
  $("#library").tablesorter({
    sortList: [[0,0]],
    headers: {
      5: {
        sorter: false
      }
    }
  });
});