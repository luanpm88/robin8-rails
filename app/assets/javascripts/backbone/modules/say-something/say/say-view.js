Robin.module('SaySomething.Say', function(Say, App, Backbone, Marionette, $, _){

  Say.SayView = Backbone.Marionette.ItemView.extend({
    template: 'modules/say-something/say/templates/say',

    events: {
      'focus form input': 'showContainer'
    },

    showContainer: function(e) {
      $(e.target).parent().parent().hide();
      $('.navbar-search-lg').show().find('textarea').focus();
      $('.progressjs-progress').show();
      return false
    }
    
  });

  Robin.vent.on("saySomething:hide", function() {
    $('.navbar-search-lg').hide();
    $('.navbar-search-sm').show().find('input').val(window.clipText($('.navbar-search-lg textarea').val(), 52));
    $('.progressjs-progress').hide();
  });



});