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
      'change #shrink-links': 'shrinkLinkProcess'
    },

    showContainer: function(e) {
      // $(e.target).parent().parent().hide();
      $('.navbar-search-lg').show().find('textarea').focus();
      $('.progressjs-progress').show();
      return false
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
    }
    
  });

  Robin.vent.on("saySomething:hide", function() {
    $('.navbar-search-lg').hide();
    $('.navbar-search-sm').show().find('input').val(window.clipText($('.navbar-search-lg textarea').val(), 52));
    $('.progressjs-progress').hide();
  });



});