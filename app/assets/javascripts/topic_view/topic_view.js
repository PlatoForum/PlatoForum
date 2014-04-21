$(function() {
  $('.expand-btn').click(function(e) {
    var expandable = $(this).parent().parent()
    if(expandable.hasClass('open') || expandable.hasClass('side') ) {
      $('.expandable-box.out').not(expandable).removeClass('out');
      expandable.removeClass('open');
      expandable.removeClass('side');
      $('.expandable-box-main').addClass("out");
      $('.stance-back').hide();
      $('.show_comment_tr.open').removeClass('open');
    }
    else {
      $('.expandable-box').not(expandable).addClass('out');
      expandable.addClass('open');
      $('.stance-back').show();
    }
  });

  var data = [
    <% @topic.stances.each do |stance| %>
    {
      value: <%= stance.comments.count %>,
      color: "<%= stance.color_code %>",
      label : "<%= stance.description %>",
      labelColor : "<%= stance.color_inverse_code %>",
      labelFontSize : "14px"
    },
    <% end %>
  ]

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
    animationEasing : "easeOutBounce",
    
    //Boolean - Whether we animate the rotation of the Pie
    animateRotate : true,

    //Boolean - Whether we animate scaling the Pie from the centre
    animateScale : false,
    
    //Function - Will fire on animation completion.
    onAnimationComplete : null
  }
  var ctx = document.getElementById("topic_statistics").getContext("2d");
  var myNewChart = new Chart(ctx).Doughnut(data,options);

});

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

      $("#main-container").html("<center><i class='fa fa-spin fa-spinner fa-2x'></i></center>");

      $.ajax({
        url: "/comment_" + data,
        dataType: "script"
      });
    }
    else {
      $("#main-container").html($("#comment_"+data+"_full").html());
    }        

    var aTag = $("div[name='main-well']");
    $('html,body').animate({scrollTop: aTag.offset().top - 70},'slow');
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
  }        

  var aTag = $("div[name='main-well']");
  $('html,body').animate({scrollTop: aTag.offset().top - 70},'slow');
  return false;
}

function click_opinion() {
  $(this).html("<i class='fa fa-spin fa-spinner fa-2x'></i>");
}
