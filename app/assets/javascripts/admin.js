//= require assets
//= require jquery
//= require jquery_ujs
//= require bootstrap-sass
//= require lib/sb-admin-2
//= require lib/metisMenu
//= require moment
//= require moment/zh-cn.js
//= require bootstrap-datetimepicker
//= require marketing_dashboard/pmes.min
//= require marketing_dashboard/common
//= require marketing_dashboard/jqzoom
//= require Chart.min

if (!jQuery.fn.size) {
  jQuery.fn.extend({
    size: function() {
      return self.length;
    }
  });
}

$(function(){
  $(".date").datetimepicker({
    ignoreReadonly: true,
    format: 'YYYY-MM-DD',
    locale: 'zh-cn'
  })

  $(".datetime").datetimepicker({
    ignoreReadonly: true,
    format: 'YYYY-MM-DD HH:mm:ss',
    // sideBySide: true,
    showClear: true,
    locale: 'zh-cn'
  })

  $('.shrink').click(function() {
    if ($(this).hasClass('active')) {
      $('.sidebar').show();
      $(this).removeClass('active');
      $('#page-wrapper').css({"margin-left": "250px"});
      $(this).css({"left": '250px'});
      $(this).find('span').removeClass('glyphicon-chevron-right').addClass('glyphicon-chevron-left');
    } else {
      $('.sidebar').hide();
      $(this).addClass('active');
      $('#page-wrapper').css({"margin-left": "0px"});
      $(this).css({"left": '0px'});
      $(this).find('span').removeClass('glyphicon-chevron-left').addClass('glyphicon-chevron-right');
    }
  })
});
