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
      'submit form': 'createPost',
      'click a.btn-default': 'showPicker',
      'click a.btn-danger' : 'hidePicker',
      'keyup #say-text'    : 'setCounter',
    },

    initialize: function() {
      this.model = new Robin.Models.Post();
      this.modelBinder = new Backbone.ModelBinder();
    },

    onRender: function() {
      this.modelBinder.bind(this.model, this.el);
    },

    ui:{
      minDatePicker: "#schedule-datetimepicker"
    },

    onRender:function() {
      this.ui.minDatePicker.datetimepicker();
      this.modelBinder.bind(this.model, this.el);
    },

    showContainer: function(e) {
      // $(e.target).parent().parent().hide();
      $('.navbar-search-lg').show().find('textarea').focus();
      $('.progressjs-progress').show();
      // return false
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
      if ($(e.target).is(':checked')) {
        var saySomethingContent = $('#say-something-field').val();
        var www_pattern = /(^|[\s\n]|<br\/?>)((www).[\-A-Z0-9+\u0026\u2019@#\/%?=()~_|!:,.;]*[\-A-Z0-9+\u0026@#\/%=~()_|])/gi
        var www_urls = saySomethingContent.match(www_pattern);
        
        if (www_urls != null) {
          $.each(www_urls, function( index, value ) {
            var result = saySomethingContent.replace(value, 'http://' + $.trim(value));
            $('#say-something-field').val(result);
          });
          var saySomethingContent = $('#say-something-field').val();
        }

        var pattern = /(^|[\s\n]|<br\/?>)((?:https?|ftp):\/\/[\-A-Z0-9+\u0026\u2019@#\/%?=()~_|!:,.;]*[\-A-Z0-9+\u0026@#\/%=~()_|])/gi
        var urls = saySomethingContent.match(pattern);

        if (urls != null) {
          $.each(urls, function( index, value ) {
            ShrinkedLink.shrink($.trim(value))
          });
        }
      } else {
        var saySomethingContent = $('#say-something-field').val();

        var pattern = /(^|[\s\n]|<br\/?>)((?:https?|ftp):\/\/[\-A-Z0-9+\u0026\u2019@#\/%?=()~_|!:,.;]*[\-A-Z0-9+\u0026@#\/%=~()_|])/gi
        var urls = saySomethingContent.match(pattern)
        if (urls != null) {
          $.each(urls, function( index, value ) {
            ShrinkedLink.unshrink($.trim(value))
          });
        }
      }
    },

    createPost: function(e) {
      e.preventDefault();
      
      this.modelBinder.copyViewValuesToModel();
      this.model.save(this.model.attributes, {
        success: function(userSession, response) {
          console.log('created');
          $.growl({message: "You've created a post"
          },{
            type: 'success'
          });
        },
        error: function(userSession, response) {
          console.log('failed');
          $.growl({title: '<strong>Error:</strong> ',
            message: 'Something went wrong.'
          },{
            type: 'danger'
          });
        }
      });
    }
    
  });

  Robin.vent.on("saySomething:hide", function() {
    $('.navbar-search-lg').hide();
    $('.navbar-search-sm').show().find('input').val(window.clipText($('.navbar-search-lg textarea').val(), 52));
    $('.progressjs-progress').hide();
  });



});