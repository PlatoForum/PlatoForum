$(function() {
  $('.expand-btn').click(function(e) {
    var expandable = $(this).parent().parent()
    if(expandable.hasClass('open')) {
      $('.expandable-box.out').not(expandable).removeClass('out');
      expandable.removeClass('open');
      $(".show_time").hide();
    }
    else {
      $('.expandable-box').not(expandable).addClass('out');
      expandable.addClass('open');
      $(".show_time").show();
    }
  });
});