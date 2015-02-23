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
      this.socialNetworksBinder = new Backbone.ModelBinder();
    },

    onRender: function(){
      $.fn.editable.defaults.mode = 'inline';
      this.$el.find('span.editable').editable();
      this.modelBinder.bind(this.model, this.el);
      sweetAlertInitialize();
    },

    events: {
      'click #delete-post': 'deletePost',
      'click span.editable': 'editPost',
      'click button[type="submit"]': 'updatePost',
      'click .social-networks .btn': 'enableSocialNetwork'
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
      
      this.socialNetworks = new Robin.Models.SocialNetworks(this.model.get('social_networks'));
      this.model.set('social_networks', this.socialNetworks);

      var socialNetworksBindings = {
        twitter: '.edit-settings-row [name=twitter]',
        facebook: '.edit-settings-row [name=facebook]',
        linkedin: '.edit-settings-row [name=linkedin]',
        google: '.edit-settings-row [name=google]'
      }
      this.modelBinder.bind(this.model, this.el);
      this.socialNetworksBinder.bind(this.model.get('social_networks'), this.el, socialNetworksBindings);
    },

    updatePost: function() {
      var view = this;
      
      view.socialNetworksBinder.copyViewValuesToModel();
      view.modelBinder.copyViewValuesToModel();

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