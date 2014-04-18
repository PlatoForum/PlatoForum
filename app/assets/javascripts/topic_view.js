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
});

function click_tr(data) {
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
