/* PlatoForum @ 2014.04.20 */
//= require ./shared/activate_media

var onready;
onready = function() {
  activate_media();
};

$(document).ready(onready);
$(document).on('page:load', onready);

function click_comment_link(data) {
  window.location.href = "/comment_" + data;
}

function click_tr(data) {
  window.location.href = "/comment_" + data;
};

function click_opinion(element) {
  element.html("<i class='fa fa-spin fa-spinner'></i>");
}