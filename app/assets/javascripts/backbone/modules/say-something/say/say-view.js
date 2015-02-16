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

var checkAbilityPosting = function(){
  var condition1 = $("#say-something-field").val().length == 0;
  var condition2 = $('.social-networks').find('.btn-primary').length == 0;

  if (condition1 || condition2) {
    $('.post-settings').find('input[type=submit]').addClass('disabled');
  } else {
    $('.post-settings').find('input[type=submit]').removeClass('disabled');
  }
};

Robin.module('SaySomething.Say', function(Say, App, Backbone, Marionette, $, _){

  Say.SayView = Backbone.Marionette.ItemView.extend({
    template: 'modules/say-something/say/templates/say',

    events: {
      'focus form input#text-field': 'showContainer',
      'change #shrink-links': 'shrinkLinkProcess',
      'submit form': 'createPost',
      'click a.btn-default': 'showPicker',
      'click a.btn-danger' : 'hidePicker',
      'keyup #say-something-field'    : 'setCounter',
      'click .social-networks .btn': 'enableSocialNetwork'
    },

    initialize: function() {
      this.model = new Robin.Models.Post();
      this.socialNetworks = new Robin.Models.SocialNetworks();
      this.model.set('social_networks', this.socialNetworks);
      this.modelBinder = new Backbone.ModelBinder();
      this.socialNetworksBinder = new Backbone.ModelBinder();
    },

    onRender: function() {
      var postBindings = {
        text: '[name=text]',
        scheduled_date: '[name=scheduled_date]'
      };
      var socialNetworksBindings = {
        twitter: '[name=twitter]',
        facebook: '[name=facebook]',
        linkedin: '[name=linkedin]',
        google: '[name=google]'
      }
      this.ui.minDatePicker.datetimepicker({minDate: moment().utc(), format: 'DD/MM/YYYY hh:mm A'});
      this.modelBinder.bind(this.model, this.el, postBindings);
      this.socialNetworksBinder.bind(this.model.get('social_networks'), this.el, socialNetworksBindings);
    },


    ui:{
      minDatePicker: "#schedule-datetimepicker"
    },

    showContainer: function(e) {
      $(e.target).parent().parent().hide();
      $('.navbar-search-lg').show().find('textarea').focus();
      $('.progressjs-progress').show();
      e.stopPropagation();
      checkAbilityPosting();
    },

    setCounter: function() {
      var prgjs = progressJs($("#say-something-field")).setOptions({ theme: 'blackRadiusInputs' }).start();
      var sayText = $("#say-something-field");
      var counter = $("#say-counter");
      var limit = 140;
      counter.text(limit - sayText.val().length);

      checkAbilityPosting();

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
            value = $.trim(value)
            var result = saySomethingContent.replace(value, 'http://' + value);
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
      this.socialNetworksBinder.copyViewValuesToModel();
      this.modelBinder.copyViewValuesToModel();
      
      if (this.model.attributes.scheduled_date === ""){
        this.model.attributes.scheduled_date = moment().utc().format('DD/MM/YYYY hh:mm A');
      } else {
        this.model.attributes.scheduled_date = moment(this.model.attributes.scheduled_date).utc();
      }

      this.model.save(this.model.attributes, {
        success: function(userSession, response) {
          $('.navbar-search-lg').hide();
          $('.navbar-search-sm').show()//.find('input').val(window.clipText($('.navbar-search-lg textarea').val(), 52));
          $('.progressjs-progress').hide();
          $.growl({message: "You've created a post"
          },{
            type: 'success'
          });
        },
        error: function(userSession, response) {
          $.growl({title: '<strong>Error:</strong> ',
            message: 'Something went wrong.'
          },{
            type: 'danger'
          });
        }
      });
    },

    enableSocialNetwork: function(e) {
      var el = $(e.target);
      var btn = el.closest('.btn');
      var input = btn.next('input');
      btn.toggleClass('btn-primary');
      if (input.val() == 'false' || input.val() == '') {
        input.val('true')
      } else {
        input.val('false')
      }
      checkAbilityPosting();
    }
    
  });
});