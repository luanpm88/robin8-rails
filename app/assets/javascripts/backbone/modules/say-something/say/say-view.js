Robin.ShrinkedLink = {
  shrink : function(url) {
    BitlyClient.shorten(url, function(data) {      
      var saySomethingContent = $('#say-something-field').val();
      var result = saySomethingContent.replace(url, _.values(data.results)[0].shortUrl);
      $('#say-something-field').val(result);
      Robin.sayView.setCounter();
    });
  },

  unshrink : function(url) {
    BitlyClient.expand(url, function(data) {
      var saySomethingContent = $('#say-something-field').val();
      var result = saySomethingContent.replace(url, _.values(data.results)[0].longUrl);
      $('#say-something-field').val(result);
      Robin.sayView.setCounter();
    });
  },
}

Robin.module('SaySomething.Say', function(Say, App, Backbone, Marionette, $, _){

  Say.SayView = Backbone.Marionette.ItemView.extend({
    template: 'modules/say-something/say/templates/say',

    events: {
      'focus form input#text-field': 'showContainer',
      'ifChanged #shrink-links': 'shrinkLinkProcess',
      'submit form': 'createPost',
      'click a.btn-default': 'showPicker',
      'click a.btn-danger': 'hidePicker',
      'keyup #say-something-field': 'setCounter',
      'click .social-networks .btn': 'enableSocialNetwork',
      'click .input-group-addon': 'changeTime'
    },

    initialize: function() {
      this.model = new Robin.Models.Post();
      this.socialNetworks = new Robin.Models.SocialNetworks();
      this.model.set('social_networks', this.socialNetworks);
      this.modelBinder = new Backbone.ModelBinder();
      this.socialNetworksBinder = new Backbone.ModelBinder();
    },

    onRender: function() {
      this.$el.find('.social-networks .btn').tooltip();

      var postBindings = {
        text: '[name=text]',
        scheduled_date: '[name=scheduled_date]',
        shrinked_links: '[name=shrinked_links]'
      };
      var socialNetworksBindings = {
        twitter: '[name=twitter]',
        facebook: '[name=facebook]',
        linkedin: '[name=linkedin]',
        // google: '[name=google]'
      }

      this.$el.find("input[type='checkbox']").iCheck({
        checkboxClass: 'icheckbox_square-blue',
        increaseArea: '20%'
      });

      this.ui.minDatePicker.datetimepicker({format: 'MM/DD/YYYY hh:mm A', minDate: moment()});
      this.modelBinder.bind(this.model, this.el, postBindings);
      this.socialNetworksBinder.bind(this.model.get('social_networks'), this.el, socialNetworksBindings);
    },

    ui:{
      minDatePicker: "#schedule-datetimepicker"
    },

    changeTime: function() {
      $('#scheduled_date').val(moment().format('MM/DD/YYYY hh:mm A'));
      $('#schedule-datetimepicker').data("DateTimePicker").minDate(moment());
    },

    showContainer: function(e) {
      $(e.target).parent().parent().hide();
      $('.navbar-search-lg').show().find('textarea').focus();
      $('.progressjs-progress').show();
      e.stopPropagation();
      this.checkAbilityPosting();
    },

    setCounter: function() {
      var prgjs = progressJs($("#say-something-field")).setOptions({ theme: 'blackRadiusInputs' }).start();
      var sayText = $("#say-something-field");
      var counter = $("#say-counter");
      var selectedNetworks = this.model.attributes.social_networks.attributes;
      var limit = 140;

      //set character limit
      if (selectedNetworks.twitter == "true") {
        limit = 140;
      } else if (selectedNetworks.linkedin == "true") {
        limit = 689;
      } else if (selectedNetworks.facebook == "true") {
        limit = 2000;
      }

      var charsLeft = limit - sayText.val().length;
      counter.text(charsLeft);

      //set color:
      if (charsLeft >= limit*0.8) {
        counter.css("background-color", "#8CC152");
      } else if (charsLeft >= limit*0.5) {
        counter.css("background-color", "#E6E300");
      } else if (charsLeft >= limit*0.2) {
        counter.css("background-color", "#FF9813");
      } else {
        counter.css("background-color", "#E62E00");
      }

      this.checkAbilityPosting();

      if (sayText.val().length <= limit) {
        prgjs.set(Math.floor(sayText.val().length * 100/limit));
      } else {
        prgjs.set(100);
      }
    },

    showPicker: function() {
      this.$el.find('a.btn-default').hide().next().show();
    },

    hidePicker: function() {
      $('div.pull-right.schedule-datetimepicker').hide().prev().show();
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
            Robin.ShrinkedLink.shrink($.trim(value));
          });
        }
      } else {
        var saySomethingContent = $('#say-something-field').val();

        var pattern = /(^|[\s\n]|<br\/?>)((?:https?|ftp):\/\/[\-A-Z0-9+\u0026\u2019@#\/%?=()~_|!:,.;]*[\-A-Z0-9+\u0026@#\/%=~()_|])/gi
        var urls = saySomethingContent.match(pattern)
        if (urls != null) {
          $.each(urls, function( index, value ) {
            Robin.ShrinkedLink.unshrink($.trim(value));
          });
        }
      }
    },

    checkAbilityPosting: function(){
      var condition1 = $("#say-something-field").val().length == 0;
      var condition2 = this.$el.find('.social-networks').find('.btn-primary').length == 0;
      var condition3 = $("#say-counter").text() < 0;
      if (condition1 || condition2 || condition3) {
        $('.post-settings').find('input[type=submit]').addClass('disabled');
      } else {
        $('.post-settings').find('input[type=submit]').removeClass('disabled');
      }
    },

    createPost: function(e) {
      e.preventDefault();
      var view = this;

      this.$el.find("#submit-post").addClass('disabled');
      var selectedDate = moment($('#scheduled_date').val());
      this.socialNetworksBinder.copyViewValuesToModel();
      this.modelBinder.copyViewValuesToModel();
      var prgjs = progressJs($("#say-something-field")).setOptions({ theme: 'blackRadiusInputs' }).end();
      if (this.model.attributes.scheduled_date === "" || selectedDate < moment()){
        this.model.attributes.scheduled_date = moment().utc();
      } else {
        this.model.attributes.scheduled_date = moment.utc(new Date(this.model.attributes.scheduled_date));
      }

      this.model.save(this.model.attributes, {
        success: function(userSession, response) {
          view.$el.find("#submit-post").removeClass('disabled');
          $('.navbar-search-lg').hide();
          $('.navbar-search-sm').show()//.find('input').val(window.clipText($('.navbar-search-lg textarea').val(), 52));
          $('.progressjs-progress').hide();

          if (Robin.Social._isInitialized){
            Robin.module("Social").postsCollection.fetch();
            Robin.module("Social").tomorrowsPostsCollection.fetch();
            Robin.module("Social").othersPostsCollection.fetch();
          }

          Robin.SaySomething.Say.Controller.showSayView();

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
      var input = btn.nextAll('input').first();
      btn.toggleClass('btn-primary');
      if (input.val() == 'false' || input.val() == '') {
        input.val('true')
      } else {
        input.val('false')
      }
      this.socialNetworksBinder.copyViewValuesToModel();
      this.setCounter();
      this.checkAbilityPosting();
    }

  });
});