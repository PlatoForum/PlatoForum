$(function() {
  $('.expand-btn').click(function(e) {
    var expandable = $(this).parent().parent()
    if(expandable.hasClass('open')) {
      $('.expandable-box.out').not(expandable).removeClass('out');
      expandable.removeClass('open');
      $(".td_short").show();
      $(".td_full").hide();
      $(".show_comment_tr").removeClass("open");
    }
    else {
      $('.expandable-box').not(expandable).addClass('out');
      expandable.addClass('open');
    }
  });
});