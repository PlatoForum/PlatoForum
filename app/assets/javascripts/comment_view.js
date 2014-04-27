/* PlatoForum @ 2014.04.20 */
//= require ./shared/activate_media

var onready;
onready = function() {
  activate_media();
};

//$(document).ready(onready);
$(document).on('page:load', onready);

function click_comment_link(data) {
  window.location.href = "/comment_" + data;
}

function click_tr(data) {
  window.location.href = "/comment_" + data;
};


$(document).on('click', '.label-opinion', function () {
  click_opinion();
});

function click_opinion() {
  $(".label-opinion").html("<i class='fa fa-spin fa-spinner'></i>");
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