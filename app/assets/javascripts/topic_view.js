/* PlatoForum @ 2014.04.20 */
//= require_tree ./topic_view/
//= require ./shared/activate_media

function scroll_top() {
  var aTag = $("div[name='main-well']");
  $('html,body').animate({scrollTop: aTag.offset().top - 70},'slow');
}

function expandable_btn(element) {
  var expandable = element.parent().parent()
  if( expandable.hasClass('open') || expandable.hasClass('side') ) {
    hideMain();
  }
  else {
    $('.expandable-box').not(expandable).addClass('out');
    expandable.addClass('open');
    $('.stance-back').show();
    scroll_top();
  }
  //e.preventDefault();
  //return false;
}

var onready;
onready = function() {
  $("a#subscribe_toggle").click(function(){
    $(this).html("<i class='fa fa-spin fa-spinner'></i>");
  });

  $(".sort-group li").click(function(){
    $(".sort-group").removeClass("open");
    $(".comment_lists").html("<center><i class='fa fa-spin fa-spinner'></i></center>");
  });

  if ( $("#topic_statistics").length > 0 ) {
    var options = {
      //Boolean - Whether we should show a stroke on each segment
      segmentShowStroke : true,
      
      //String - The colour of each segment stroke
      segmentStrokeColor : "#fff",
      
      //Number - The width of each segment stroke
      segmentStrokeWidth : 2,
      
      //Boolean - Whether we should animate the chart 
      animation : true,
      
      //Number - Amount of animation steps
      animationSteps : 100,
      
      //String - Animation easing effect
      animationEasing : "easeOutQuint",
      
      //Boolean - Whether we animate the rotation of the Pie
      animateRotate : true,

      //Boolean - Whether we animate scaling the Pie from the centre
      animateScale : true,
      
      //Function - Will fire on animation completion.
      onAnimationComplete : null
    }
    var ctx = document.getElementById("topic_statistics").getContext("2d");
    var myNewChart = new Chart(ctx).Doughnut(data,options); 
  }
};

$(document).on('page:load', onready);
//$(document).ready(onready);

$(document).keydown(function (e) {
  if ((e.which === 8 || e.which === 27) && !$('.modal').hasClass('in') ) {
    hideMain();
    return false;
  }
});

function hideMain() {
  $('.expandable-box.out').removeClass('out');
  $('.expandable-box.open').removeClass('open');
  $('.expandable-box.side').removeClass('side');
  $('.expandable-box-main').addClass("out");
  $('.stance-back').hide();
  $('.show_comment_tr.open').removeClass('open');

  var aTag = $("div[name='main-well']");
  $('html,body').animate({scrollTop: aTag.offset().top - 70},'slow');
}

function click_tr(data) {
  if ( !$("#tr_"+data).hasClass("open") ) {
    $('.stance-back').show();
    $('.show_comment_tr.open').not($("#tr_"+data)).removeClass('open');
    $("#tr_"+data).addClass("open");

    var expandable = $("#tr_"+data).parents().eq(4);;
    $('.expandable-box').not(expandable).addClass('out');
    expandable.addClass('side');
    $('.expandable-box-main').removeClass('out');

    if ( !$("#comment_pool").hasClass(data) ) {

      $("#main-container").html("<div class='holder_"+data+"'><center><i class='fa fa-spin fa-spinner fa-2x'></i></center></div>");

      $.ajax({
        url: "/comment_" + data,
        dataType: "script"
      });
    }
    else {
      $("#main-container").html($("#comment_"+data+"_full").html());
      activate_media(data);
    }        

    scroll_top();
  }
  return false;
};

function click_comment_link(data) {
  $('.show_comment_tr.open').removeClass('open');

  if ( !$("#comment_pool").hasClass(data) ) {

    $("#main-container").html("<center><i class='fa fa-spin fa-spinner fa-2x'></i></center>");

    $.ajax({
      url: "/comment_" + data,
      dataType: "script"
    });
  }
  else {
    $("#main-container").html($("#comment_"+data+"_full").html());
    activate_media(data);
  }        

  scroll_top();
  return false;
}

function expand_reply(element) {
  var expandable = element.parent();
  if (expandable.hasClass("panel-closed")) {
    expandable.removeClass("panel-closed");

    var data = expandable.attr("id");
    if ( !$("#comment_pool").hasClass(data) ) {

      $(".panel-body", expandable).html("<div class='holder_"+data+"'><center><i class='fa fa-spin fa-spinner fa-2x'></i></center></div>");

      $.ajax({
        url: "/comment_" + data,
        dataType: "script"
      });
    }
    else {
      $(".panel-body", expandable).html($("#comment_"+data+"_full").html());
      activate_media(data);
    }        
  }
  else {
    expandable.addClass("panel-closed");
    //$(".panel-body", expandable).html("");
  }
}

$(document).on('click', '.label-opinion', function () {
  click_opinion();
});

function click_opinion() {
  $(".label-opinion").html("<i class='fa fa-spin fa-spinner'></i>");
}

function takeover(element) {
  var expandable = element.parent().parent().parent();
  $("#main-container").html(expandable.html());

  $('.show_comment_tr.open').removeClass('open');
  scroll_top();
}
