Robin.module('Social.Show', function(Show, App, Backbone, Marionette, $, _){
  
  Show.ScheduledEmptyToday = Backbone.Marionette.ItemView.extend({
    template: 'modules/social/show/templates/_scheduled-empty',
    tagName: "li",
    onShow: function(){
      this.$el.parent().parent().find('#today').hide();
    }
  });

  Show.ScheduledEmptyTomorrow = Backbone.Marionette.ItemView.extend({
    template: 'modules/social/show/templates/_scheduled-empty',
    tagName: "li",
    onShow: function(){
      this.$el.parent().parent().find('#tomorrow').hide();
    }
  });

  Show.ScheduledEmptyOther = Backbone.Marionette.ItemView.extend({
    template: 'modules/social/show/templates/_scheduled-empty',
    tagName: "li",
    onShow: function(){
      this.$el.parent().parent().find('#others').hide();
    }
  });

  Show.ScheduledPost = Backbone.Marionette.ItemView.extend({
    template: 'modules/social/show/templates/_scheduled-post',
    tagName: "li",
    className: "list-group-item",
    model: Robin.Models.Post,

    initialize: function() {
      this.modelBinder = new Backbone.ModelBinder();
      this.socialNetworksBinder = new Backbone.ModelBinder();
      this.socialNetworksBindings = {
        twitter: '.edit-settings-row [name=twitter]',
        facebook: '.edit-settings-row [name=facebook]',
        linkedin: '.edit-settings-row [name=linkedin]',
        // google: '.edit-settings-row [name=google]'
      };
      this.progressBar = null;
      viewObj = this;

      Robin.vent.on("social:networksClicked", function() {
        if ($('.editable-container').length>0) {
          Robin.vent.trigger("social:showPosts");
          swal({
            title: "Discard all unsaved changes?",
            text: "You have not finished editing some of your posts. Leaving this view will discard all unsaved changes",
            type: "error",
            showCancelButton: true,
            confirmButtonClass: 'btn-danger',
            confirmButtonText: 'Discard changes',
            cancelButtonText: 'Continue editing'
          },
          function(isConfirm) {
            if (isConfirm) {
              $('.editable-cancel').click();
              Robin.vent.trigger("social:showProfiles");
            }
          });
        }
      });
    },

    onRender: function(){
      var view = this;

      $.fn.editable.defaults.mode = 'inline';
      $.fn.editable.defaults.onblur = 'ignore';
      $.fn.editable.defaults.inputclass = 'editable-post';
      view.$el.find('span.editable').editable().on('hidden', function(e, reason) {
        view.$el.find('.edit-post').removeClass('disabled');
        view.$el.find('.social-networks a').removeClass('disabled');
        if(reason === 'cancel') {
          view.model.fetch({
            success: function(){
              view.modelBinder.bind(view.model, view.el);
              view.render();
            }
          });
        }
      }).on('shown', function(e, reason) {
        view.$el.find('.edit-post').addClass('disabled');
        view.$el.find('.social-networks a').addClass('disabled');
        
        view.interval = window.setInterval((function() {
          renderedCheckbox = view.$el.find(".editableform #edit-shrink-links")
          if (renderedCheckbox.length != 0) {
            
            // set date to utc format
            var utcDate = moment.utc(view.model.attributes.scheduled_date).toDate();
            var datedate = moment(utcDate).format('MM/DD/YYYY hh:mm A');

            $('.editableform .edit-datetimepicker').find('input').val(datedate).change();
            $('.editableform .edit-datetimepicker').datetimepicker();

            renderedCheckbox.iCheck({
              checkboxClass: 'icheckbox_square-blue',
              increaseArea: '20%'
            });
            window.clearInterval(view.interval);
          }
        }), 50);
      });

      view.modelBinder.bind(view.model, view.el);
      sweetAlertInitialize();
    },

    events: {
      'click #delete-post': 'deletePost',
      'click span.editable': 'editPost',
      'click button[type="submit"]': 'updatePost',
      'click .social-networks .btn': 'enableSocialNetwork',
      'click .edit-social-networks .btn': 'editSocialNetwork',
      'click .edit-post': 'enableEditableMode',
      'ifChanged #edit-shrink-links': 'shrinkLinkProcess',
      'keyup #edit-post-textarea' : 'setCounter',
      'focus #edit-post-textarea': 'setCounter',
      'focusout #edit-post-textarea': 'hideCounter'
    },

    enableEditableMode: function(e) {
      e.stopPropagation();
      this.$el.find('span.editable').editable('show');
      this.editPost();
    },

    editSocialNetwork: function(e) {
      var el = $(e.target);
      var btn = el.closest('.btn');
      var input = btn.next('input');
      var oldLimit = this.countLimit(this.model.attributes.social_networks.attributes);
      var initialSelected = 0;
      $.each(this.model.attributes.social_networks.attributes, function( index, value ) {
        if (value == 'true') initialSelected+=1;
      });

      if (input.val() == 'false' || input.val() == '') {
        input.val('true')
      } else if (input.val() == 'true' && initialSelected == 1) {
        btn.toggleClass('btn-primary');
        input.val('true');
        swal({
          title: "You can not disable this social network",
          text: "At least one should be selected in order to publish the post!",
          type: "error",
          showCancelButton: false,
          confirmButtonClass: 'btn',
          confirmButtonText: 'ok'
        });
      } else {
        input.val('false')
      }

      var networksTemporary = new Object;
      var inputs = this.$el.find('.editable-input .edit-social-networks input');
      $.each(inputs, function(index, value) {
        networksTemporary[value.name] = value.value;
      });
      var newLimit = this.countLimit(networksTemporary);
      var textLength  = this.$el.find('#edit-post-textarea').val().length;
      var viewObj = this;

      if (textLength > newLimit) {
        swal({
          title: "Trim the message?",
          text: "Your message exceeds the limit of one of the selected social networks (" + textLength + "/" + newLimit + "). Proceed and trim the message? NOTE: This can not be undone!",
          type: "error",
          showCancelButton: true,
          confirmButtonClass: 'btn-danger',
          confirmButtonText: 'Trim the message'
        },
        function(isConfirm) {
          if (isConfirm) {
            btn.toggleClass('btn-primary');
            viewObj.socialNetworksBinder.copyViewValuesToModel();
            viewObj.setCounter();
          }
        });
      } else {
        btn.toggleClass('btn-primary');
        this.socialNetworksBinder.copyViewValuesToModel();
        this.setCounter();
      }
    },

    enableSocialNetwork: function(e) {
      var initialSelected = 0;
      $.each(this.model.attributes.social_networks, function( index, value ) {
        if (value == 'true') initialSelected+=1;
      });

      var el = $(e.target);
      var btn = el.closest('.btn');

      var provider = $(btn).data('provider');
      var tempNetworks = (new Robin.Models.SocialNetworks(this.model.get('social_networks'))).attributes;
      var providerValue = tempNetworks[provider];
      var oldLimit = this.countLimit(tempNetworks);

      if (providerValue == 'false' || providerValue == '') {
        tempNetworks[provider] = 'true';
      } else if (providerValue == 'true' && initialSelected == 1) {
        tempNetworks[provider] = 'true';
        swal({
          title: "You can not disable this social network",
          text: "At least one should be selected in order to publish the post!",
          type: "error",
          showCancelButton: false,
          confirmButtonClass: 'btn',
          confirmButtonText: 'ok'
        });
      } else {
        tempNetworks[provider] = 'false';
      } 

      var view = this;
      var newLimit = this.countLimit(tempNetworks);
      
      var textLength = this.model.attributes.text.length;

      if (textLength > newLimit && newLimit > 0) {
        var trimmedText = this.model.attributes.text.substring(0, newLimit)
        swal({
          title: "Trim the message?",
          text: "Your message exceeds the limit of one of the selected social networks (" + textLength + "/" + newLimit + "). Proceed and trim the message? NOTE: This can not be undone!",
          type: "error",
          showCancelButton: true,
          confirmButtonClass: 'btn-danger',
          confirmButtonText: 'Trim the message'
        },
        function(isConfirm) {
          if (isConfirm) {
            view.model.attributes.text = trimmedText;
            view.model.attributes.social_networks[provider] = tempNetworks[provider];
            view.model.updateSocial(view.model.attributes.social_networks);
            view.updatePost();
          }
        });
      } else {
        var view = this;
        view.model.attributes.social_networks[provider] = tempNetworks[provider];
        view.model.updateSocial(view.model.attributes.social_networks).done(function(data){
          view.render();
        });
      }
    },

    shrinkLinkProcess: function(e) {
      var view = this;
      if ($(e.target).is(':checked')) {
        var editPostContent = view.$el.find('#edit-post-textarea').val();
        var www_pattern = /(^|[\s\n]|<br\/?>)((www).[\-A-Z0-9+\u0026\u2019@#\/%?=()~_|!:,.;]*[\-A-Z0-9+\u0026@#\/%=~()_|])/gi
        var www_urls = editPostContent.match(www_pattern);
        
        if (www_urls != null) {
          $.each(www_urls, function( index, value ) {
            value = $.trim(value)
            var result = editPostContent.replace(value, 'http://' + value);
            view.$el.find('#edit-post-textarea').val(result);
          });
          var editPostContent = view.$el.find('#edit-post-textarea').val();
        }

        var pattern = /(^|[\s\n]|<br\/?>)((?:https?|ftp):\/\/[\-A-Z0-9+\u0026\u2019@#\/%?=()~_|!:,.;]*[\-A-Z0-9+\u0026@#\/%=~()_|])/gi
        var urls = editPostContent.match(pattern);

        if (urls != null) {
          $.each(urls, function( index, value ) {
            var url = $.trim(value)
            BitlyClient.shorten(url, function(data) {
              var saySomethingContent = view.$el.find('#edit-post-textarea').val();
              var result = saySomethingContent.replace(url, _.values(data.results)[0].shortUrl);
              view.$el.find('#edit-post-textarea').val(result);
            });
          });
        }
      } else {
        var editPostContent = view.$el.find('#edit-post-textarea').val();

        var pattern = /(^|[\s\n]|<br\/?>)((?:https?|ftp):\/\/[\-A-Z0-9+\u0026\u2019@#\/%?=()~_|!:,.;]*[\-A-Z0-9+\u0026@#\/%=~()_|])/gi
        var urls = editPostContent.match(pattern)
        if (urls != null) {
          $.each(urls, function( index, value ) {
            var url = $.trim(value)
            BitlyClient.expand(url, function(data) {
              var saySomethingContent = view.$el.find('#edit-post-textarea').val();
              var result = saySomethingContent.replace(url, _.values(data.results)[0].longUrl);
              view.$el.find('#edit-post-textarea').val(result);
            });
          });
        }
      }
    },

    deletePost: function(e) {
      var r = this.model;
      swal({
        title: "Delete Post?",
        text: "You will not be able to recover this post.",
        type: "error",
        showCancelButton: true,
        confirmButtonClass: 'btn-danger',
        confirmButtonText: 'Delete'
      },
      function(isConfirm) {
        if (isConfirm) {
          r.destroy({ dataType: "text"});
        }
      });
    },

    editPost: function() {
      var row = this.$el.find('.edit-settings-row').clone();
      row.removeClass('hidden');
      this.$el.find('textarea').parent().append(row);
      this.$el.find('textarea').attr('name', 'text');
      this.$el.find('textarea').attr('id', 'edit-post-textarea');
      this.$el.find('textarea').width("600px");
      this.socialNetworks = new Robin.Models.SocialNetworks(this.model.get('social_networks'));
      this.model.set('social_networks', this.socialNetworks);

      var postBindings = {
        text: '[name=text]',
        scheduled_date: '[name=scheduled_date]',
        shrinked_links: '[name=shrinked_links]'
      };
      this.modelBinder.bind(this.model, this.el, postBindings);
      this.socialNetworksBinder.bind(this.model.get('social_networks'), this.el, this.socialNetworksBindings);

      //Counter here
      var selectedNetworks = this.socialNetworks.attributes;
      var limit = this.countLimit(selectedNetworks);
      var counter = this.$el.find('.post-counter');
      var charsLeft = limit - this.$el.find('textarea').val().length
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
    },

    updatePost: function() {
      var view = this;
      view.socialNetworksBinder.copyViewValuesToModel();
      view.modelBinder.copyViewValuesToModel();

      view.model.attributes.scheduled_date = moment(new Date(view.model.attributes.scheduled_date));
      view.model.save(view.model.attributes, {
        success: function(data){
          Robin.module("Social").postsCollection.fetch().then(function() {
            Robin.module("Social").postsView.render();
          });
          Robin.module("Social").tomorrowsPostsCollection.fetch().then(function() {
            Robin.module("Social").tomorrowPostsView.render();
          });
          Robin.module("Social").othersPostsCollection.fetch().then(function() {
            Robin.module("Social").othersPostsView.render();
          });
        },
        error: function(data){
          console.warn('error', data);
        }
      });
    },

    setCounter: function() {
      var sayText = this.$el.find("#edit-post-textarea");
      var counter = this.$el.find('div.edit-settings-row:nth-child(2)').find('#edit-counter');
      var prgjs = progressJs(sayText).setOptions({ theme: 'blackRadiusInputs' }).start();
      var limit = 140;
      var selectedNetworks = this.model.attributes.social_networks.attributes;

      //set character limit
      limit = this.countLimit(selectedNetworks);
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

      if (sayText.val().length <= limit) {
        prgjs.set(Math.floor(sayText.val().length * 100/limit));
        this.$el.find('.editable-submit').removeClass('disabled');
      } else {
        prgjs.set(100);
        this.$el.find('.editable-submit').addClass('disabled');
      }
    },

    hideCounter: function() {
      $('.progressjs-inner').hide();
      var prgjs = progressJs(this.$el.find("#edit-post-textarea")).setOptions({ theme: 'blackRadiusInputs' }).end();
    },

    countLimit: function(networks) {
      var limit;
      if (networks.twitter == "true") {
        limit = 140;
      } else if (networks.linkedin == "true") {
        limit = 689;
      } else if (networks.facebook == "true") {
        limit = 2000;
      } else {
        limit = 0;
      }
      return limit
    }

  });

  Show.GeneralPostsView = Backbone.Marionette.LayoutView.extend({
    template: 'modules/social/show/templates/scheduled-posts',

    regions: {
      today: "#today-posts",
      tomorrow: "#tomorrow-posts",
      other: "#other-posts",
    },

    onRender: function() {
      var currentView = this;
      currentView.getRegion('today').show(Robin.module("Social").postsView);
      currentView.getRegion('tomorrow').show(Robin.module("Social").tomorrowPostsView);
      currentView.getRegion('other').show(Robin.module("Social").othersPostsView);
    },

  });
   
  Show.TodayPostsComposite = Backbone.Marionette.CompositeView.extend({
    collection: Robin.Collections.Posts,
    template: "modules/social/show/templates/todays",
    childView: Show.ScheduledPost,
    childViewContainer: "ul",
    emptyView: Show.ScheduledEmptyToday,
    
    collectionEvents: {
      "sync": "sync"
    },

    initialize: function() {
      this.collection.fetch({
        success: function(model, response){
          if (model.length===0) {
            this.parent.$("#today").hide().prev().show();
          }
        }
      });
    },

    sync: function() {
      if (this.collection.length > 0) {
        this.$el.parent().find("#today").show();
      }
    },

  });

  Show.TomorrowPostsComposite = Backbone.Marionette.CompositeView.extend({
    collection: Robin.Collections.Posts,
    template: "modules/social/show/templates/tomorrows",
    childView: Show.ScheduledPost,
    childViewContainer: "ul",
    emptyView: Show.ScheduledEmptyTomorrow,

    collectionEvents: {
      "sync": "sync"
    },

    initialize: function() {
      this.collection.fetch({
        success: function(model, response){
          if (model.length===0) {
            this.parent.$("#tomorrow").hide().prev().show();
          }
        }
      });
    },

    sync: function() {
      if (this.collection.length > 0) {
        this.$el.parent().find("#tomorrow").show();
      }
    },
  });

  Show.OthersPostsComposite = Backbone.Marionette.CompositeView.extend({
    collection: Robin.Collections.Posts,
    template: "modules/social/show/templates/others",
    childView: Show.ScheduledPost,
    childViewContainer: "ul",
    emptyView: Show.ScheduledEmptyOther,

      collectionEvents: {
      "sync": "sync"
    },

    initialize: function() {
      this.collection.fetch({
        success: function(model, response){
          if (model.length===0) {
            this.parent.$("#others").hide().prev().show();
          }
        }
      });
    },

    sync: function() {
      if (this.collection.length > 0) {
        this.$el.parent().find("#others").show();
      }
    },
  });

});