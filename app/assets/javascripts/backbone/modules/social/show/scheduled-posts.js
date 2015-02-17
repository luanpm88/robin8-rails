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
      $.fn.editable.defaults.mode = 'inline';
      this.$el.find('span.editable').editable();
      this.modelBinder.bind(this.model, this.el);
      sweetAlertInitialize();
    },

    events: {
      'click #delete-post': 'deletePost',
      'click span.editable': 'editPost',
      'click button[type="submit"]': 'updatePost'
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
      this.$el.find('textarea').attr('name', 'text')
      this.modelBinder.bind(this.model, this.el);
    },

    updatePost: function() {
      this.modelBinder.copyViewValuesToModel();
      this.model.save(this.model.attributes, {
        success: function(data){
          console.log(data);
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