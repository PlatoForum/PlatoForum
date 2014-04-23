/* Hsuan Lee @ 2014.04.20 */

var imgStr = "\.(jpg|gif|png)+"
var youtubeStr = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/;

// Expand <a /> with its associate application, ex. img, youtube
function activate_media(){
  $("#main-container .comment_bodies a").filter(function(){
      // image url
    var url = $(this).attr("href");
    if( url.match(imgStr)) {
      $(this).html($("<img>").attr("src",url).addClass("comment_img"));
    }
    // youtube url
    var yt_match = url.match(youtubeStr);  // dessemble youtube url into fields
    if( yt_match && yt_match[7].length==11) {

      $(this).replaceWith("<div class='youtube-iframe'><iframe src='//www.youtube.com/embed/" + yt_match[7] + "' frameborder='0' allowfullscreen></iframe></div>");
    }
  });
}

function click_comment_link(data) {
  $('.show_comment_tr.open').removeClass('open');

  if ( !$("#comment_pool").hasClass(data) ) {

    $("#main-container").html("<center><i class='fa fa-spin fa-spinner fa-2x'></i></center>");

    $.ajax({
      url: "/comment_with_reference_" + data+ "?with_ref=true",
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

function click_tr(data) {
  $('.show_comment_tr.open').not($("#tr_"+data)).removeClass('open');
  $("#tr_"+data).addClass("open");

  if ( !$("#comment_pool").hasClass(data) ) {

    $("#main-container").html("<center><i class='fa fa-spin fa-spinner fa-2x'></i></center>");

    $.ajax({
      url: "/comment_" + data + "?with_ref=true",
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