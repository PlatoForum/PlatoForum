$(function() {
  $('.expand-btn').click(function(e) {
    var expandable = $(this).parent().parent()
    if(expandable.hasClass('open')) {
      $('.expandable-box.out').not(expandable).removeClass('out');
      expandable.removeClass('open');
    }
    else {
      $('.expandable-box').not(expandable).addClass('out');
      expandable.addClass('open');
    }
  });
});