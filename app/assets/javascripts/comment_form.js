/* PlatoForum @ 2014.04.20 */

//= require_tree ./comment_form/

var imgStr = "\.(jpg|gif|png)+"
var youtubeStr = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/;

function check_and_preview(event) {
  var success = true;

  if ($("#comment_stance").val() == "") {
    success = false;
    $("#comment_stance").parent().parent().addClass("has-error");
  }
  else {
    $("#comment_stance").parent().parent().removeClass("has-error");
  }

  if ($("#comment_subject").val() == "" || $("#comment_subject").val().length > 50) {
    success = false;
    $("#comment_subject").parent().parent().addClass("has-error");
  }
  else {
    $("#comment_subject").parent().parent().removeClass("has-error");
  }

  if ($("#comment_body").val() == "") {
    success = false;
    $("#comment_body").parent().parent().addClass("has-error");
  }
  else {
    $("#comment_body").parent().parent().removeClass("has-error");
  }

  if ( success ) {
    $("#preview-subject").html($("#comment_subject").val());
    $("#preview-stance").html("立場：<span class='text-" + $("#button_"+ $("#comment_stance").val()).attr("color") + "'>" + $("#button_"+ $("#comment_stance").val()).attr("desc") + "</span>");
    
    if ($("#comment_tag").length == 0 || $("#comment_tag").val() == "") {
      $("#preview-quote").hide();
    }
    else {
      $("#preview-quote").show();
      var tag_url;
      if ($("#comment_tag_url").val() == "") { tag_url = "#" }
      else { tag_url = $("#comment_tag_url").val() }
      $("#preview-quote").html("轉錄自 <a class='label label-primary' target='_blank' href='" +  tag_url +"'> " + $("#comment_tag").val() +" </a>" );
    }

    $("#preview-body").html( content_processor($("#comment_body").val()) );
    $("#preview-body a").filter(function(){
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

    $("#modal_preview").modal("show");
  }
  else
  {
    event.preventDefault();
  }
}