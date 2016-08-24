//= require assets
//= require jquery
//= require jquery_ujs
//= require bootstrap-sass
//= require lib/sb-admin-2
//= require lib/metisMenu
//= require momentjs
//= require momentjs/locale/zh-cn
//= require eonasdan-bootstrap-datetimepicker

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
});
