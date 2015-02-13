Robin.module('Social.Show', function(Show, App, Backbone, Marionette, $, _){
  
  Show.ScheduledEmptyView = Backbone.Marionette.ItemView.extend({
    template: 'modules/social/show/templates/_scheduled-empty',
    tagName: "li",
    onRender: function(){
      console.log(this.$el.closest('#today').length);
      $('#today').hide();
    }
  });

  Show.ScheduledPost = Backbone.Marionette.ItemView.extend({
    template: 'modules/social/show/templates/_scheduled-post',
    tagName: "li",
    className: "list-group-item",
    model: Robin.Models.Post,
    serializeData : function() {
      return {
        text: this.model.get('text'),
        scheduled_date: this.model.get('scheduled_date')
      };
    },

    onRender: function(){
      $.fn.editable.defaults.mode = 'inline';
      this.$el.find('span.editable').editable();
    },

    events: {
      'click #delete-post': 'deletePost',
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

    isEmpty: function(collection) {
      return true;
    }

  });

});