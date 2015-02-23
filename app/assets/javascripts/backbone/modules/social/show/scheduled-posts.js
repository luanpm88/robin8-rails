Robin.module('Social.Show', function(Show, App, Backbone, Marionette, $, _){
  
  Show.ScheduledEmptyView = Backbone.Marionette.ItemView.extend({
    template: 'modules/social/show/templates/_scheduled-empty',
    tagName: "li",
    onRender: function(){
      $('#today').hide();
    }
  });

  Show.ScheduledPost = Backbone.Marionette.ItemView.extend({
    template: 'modules/social/show/templates/_scheduled-post',
    tagName: "li",
    className: "list-group-item",
    model: Robin.Models.Post,

    initialize: function() {
      this.modelBinder = new Backbone.ModelBinder();
    },

    onRender: function(){
      var view = this;

      $.fn.editable.defaults.mode = 'inline';
      view.$el.find('span.editable').editable().on('hidden', function(e, reason) {
        view.$el.find('.edit-post').removeClass('disabled');
        // view.$el.find('.edit-datetimepicker').datetimepicker('destroy');
      }).on('shown', function(e, reason) {
        view.$el.find('.edit-post').addClass('disabled');
      });

      view.modelBinder.bind(view.model, view.el);
      sweetAlertInitialize();
    },

    events: {
      'click #delete-post': 'deletePost',
      'click span.editable': 'editPost',
      'click button[type="submit"]': 'updatePost',
      'click .social-networks .btn': 'enableSocialNetwork',
      'click .edit-post': 'enableEditableMode',
    },

    enableEditableMode: function(e) {
      e.stopPropagation();
      this.$el.find('span.editable').editable('show');
      this.editPost();
    },

    enableSocialNetwork: function(e) {
      var el = $(e.target);
      var btn = el.closest('.btn');
      
      var provider = $(btn).data('provider');
      var providerValue = this.model.attributes.social_networks[provider];

      if (providerValue == 'false' || providerValue == '') {
        this.model.attributes.social_networks[provider] = 'true'
      } else {
        this.model.attributes.social_networks[provider] = 'false'
      }

      this.model.save(this.model.attributes, {
        success: function(data){
          btn.toggleClass('btn-primary');
        },
        error: function(data){
          console.warn('error', data);
        }
      });
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
      this.$el.find('textarea').parent().append(row);
      row.removeClass('hidden');
      this.$el.find('textarea').attr('name', 'text')
      
      var postBindings = {
        text: '[name=text]',
        scheduled_date: '[name=scheduled_date]',
        shrinked_links: '[name=shrinked_links]'
      };
      this.modelBinder.bind(this.model, this.el, postBindings);

      $('.edit-datetimepicker').datetimepicker({format: 'MM/DD/YYYY hh:mm A'});
    },

    updatePost: function() {
      var view = this;
      view.modelBinder.copyViewValuesToModel();

      view.model.attributes.scheduled_date = moment(new Date(view.model.attributes.scheduled_date)).utc();
      view.model.save(view.model.attributes, {
        success: function(data){
          view.render();
        },
        error: function(data){
          console.warn('error', data);
        }
      });
    }

  });
  
  Show.ScheduledPostsComposite = Backbone.Marionette.CompositeView.extend({
    collection: Robin.Collections.Posts,
    template: "modules/social/show/templates/scheduled-posts",
    childView: Show.ScheduledPost,
    childViewContainer: "ul",
    emptyView: Show.ScheduledEmptyView,
    initialize: function() {
      this.collection.fetch({
        success: function(model, response){
          if (model.length===0) {
            this.parent.$("#today").hide().prev().show();
          }
        }
      });
    },

  });

});