// Utils
window.capitalize = function(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

window.clipText = function(string, length) {
  return (string.length > length) ? string.substring(0,length-3) + '...' : string;
}

$(function(){
  var inits = {};

  // Navigation
  $('#sidebar li a').on('click', function() {
    $('#sidebar li.active').removeClass('active');
    $(this).parent().addClass('active');
    var tab = $(this).attr('id').replace('nav-','');
    $('.page-content').html(_.template($('#_'+tab).text(),{}));
    if(inits[tab]) inits[tab]();
  });
  // End Navigation

  // Social post dialog
  $('.navbar-search-lg textarea').keydown(function(e){
    if (e.keyCode == 13 && !e.shiftKey) {
      e.preventDefault();
      return false;
    }
  });

  $('.navbar-search .post-settings .schedule').on('click', function(){
    $(this).hide().next().show();
  });

  $('.navbar-search .post-settings .cancel-schedule').on('click', function(){
    $(this).parent().hide().prev().show();
  });

  $('.navbar-search .post-settings .social-networks .btn').on('click', function(){
    $(this).toggleClass('btn-primary');
  }).tooltip();

  $('.navbar-search-sm input').on('focus', function(){
    $(this).parent().parent().hide();
    $('.navbar-search-lg').show().find('textarea').focus();
    $('.progressjs-progress').show();
  });

  $('html').click(function() {
    $('.navbar-search-lg').hide();
    $('.navbar-search-sm').show().find('input').val(window.clipText($('.navbar-search-lg textarea').val(), 52));
    $('.progressjs-progress').hide();
  });

  $('.navbar-search-lg').click(function(event){
      event.stopPropagation();
  });

  $('.navbar-search-lg textarea').on('keyup', function() {
    var prgjs = progressJs($(this)).setOptions({ theme: 'blackRadiusInputs' }).start();
    var counter = $(this).parent().find(".post-counter");
    var limit = 140; // determined based on selected social networks

    counter.text(limit - this.value.length);

    if (this.value.length <= limit) {
      prgjs.set(Math.floor(this.value.length * 100/limit));
    } else {
      this.value = this.value.substring(0, limit);
    }
  });

});
