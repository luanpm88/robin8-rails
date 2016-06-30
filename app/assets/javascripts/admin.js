//= require assets
//= require jquery
//= require jquery_ujs
//= require bootstrap-sass
//= require lib/sb-admin-2
//= require lib/metisMenu
//= require momentjs
//= require momentjs/locale/zh-cn
//= require eonasdan-bootstrap-datetimepicker

$(function(){
  $(".date").datetimepicker({
    ignoreReadonly: true,
    format: 'YYYY-MM-DD',
    locale: 'zh-cn'
  })
});
