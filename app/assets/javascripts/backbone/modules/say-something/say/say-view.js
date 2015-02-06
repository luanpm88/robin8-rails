var ShrinkedLink = {
  shrink : function(url) {
    BitlyClient.shorten(url, function(data) {
      var saySomethingContent = $('#say-something-field').val();
      var result = saySomethingContent.replace(url, _.values(data.results)[0].shortUrl);
      $('#say-something-field').val(result);
    });
  },

  unshrink : function(url) {
    BitlyClient.expand(url, function(data) {
      var saySomethingContent = $('#say-something-field').val();
      var result = saySomethingContent.replace(url, _.values(data.results)[0].longUrl);
      $('#say-something-field').val(result);
    });
  },
}

Robin.module('SaySomething.Say', function(Say, App, Backbone, Marionette, $, _){

  Say.SayView = Backbone.Marionette.ItemView.extend({
    template: 'modules/say-something/say/templates/say',

    events: {
      'focus form input': 'showContainer',
      'change #shrink-links': 'shrinkLinkProcess',
      'click a.btn-default': 'showPicker',
      'click a.btn-danger' : 'hidePicker',
      'keyup #say-text'    : 'setCounter',
    },

    ui:{
      minDatePicker: "#schedule-datetimepicker"
    },

    onRender:function() {
      this.ui.minDatePicker.datetimepicker();
      //console.log(this.ui.minDatePicker);
    },

    showContainer: function(e) {
      // $(e.target).parent().parent().hide();
      $('.navbar-search-lg').show().find('textarea').focus();
      $('.progressjs-progress').show();
      return false
    },

    setCounter: function() {
      var prgjs = progressJs($("#say-text")).setOptions({ theme: 'blackRadiusInputs' }).start();
      var sayText = $("#say-text");
      var counter = $("#say-counter");
      var limit = 140;
      counter.text(limit - sayText.val().length);

      if (sayText.val().length <= limit) {
        prgjs.set(Math.floor(sayText.val().length * 100/limit));
      } else {
        var t = sayText.val().substring(0, limit);
        sayText.val(t);
        counter.text(0);
      }
    },

    showPicker: function() {
      $('a.btn-default').hide().next().show();
    },

    hidePicker: function() {
      $('div.pull-right').hide().prev().show();
    },

    shrinkLinkProcess: function(e) {
      var saySomethingContent = $('#say-something-field').val();
      if ($(e.target).is(':checked')) {
        // var regexp = /(\b(https?|www):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/i
        // var urls = regexp.exec(saySomethingContent)
        // $.each(urls, function( index, value ) {
          // console.log(value);
        ShrinkedLink.shrink(saySomethingContent)
        // });
      } else {
        
        // $.each(urls, function( index, value ) {
        ShrinkedLink.unshrink(saySomethingContent)
        // });
      }
    }
    
  });

  Robin.vent.on("saySomething:hide", function() {
    $('.navbar-search-lg').hide();
    $('.navbar-search-sm').show().find('input').val(window.clipText($('.navbar-search-lg textarea').val(), 52));
    $('.progressjs-progress').hide();
  });



});