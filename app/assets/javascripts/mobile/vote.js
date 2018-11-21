$(document).ready(function() {
  if ($('body').attr('id') === 'mobile_pages_vote') {
    var $vote_countdown = $('#vote_countdown');
    var countdown_datetime = $vote_countdown.data('datetime');
    countDownTimer($vote_countdown, countdown_datetime);

    var $tab_control = $('.user-info-panel');
    $tab_control.find('.tab-ctrl').on('click', '.item', function(){
      var $that = $(this),
          index = $that.index(),
          $tags = $tab_control.find('.tab-ctrl'),
          $content = $tab_control.find('.tab-content');
      $that.siblings('.item').removeClass('active');
      $that.addClass('active');
      $content.eq(index).siblings('.tab-content').removeClass('active');
      $content.eq(index).addClass('active');
    });
  }
});
