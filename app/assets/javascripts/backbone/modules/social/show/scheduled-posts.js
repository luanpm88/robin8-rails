Robin.module('Social.Show', function(Show, App, Backbone, Marionette, $, _){
  
  Show.ScheduledPost = Backbone.Marionette.ItemView.extend({
    template: 'modules/social/show/templates/_scheduled_post',
    tagName: "li",
    className: "list-group-item",
    model: Robin.Models.Post,
    serializeData : function() {
      window.$thisModel = this.model;
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
    template: "modules/social/show/templates/scheduled_posts",
    childView: Show.ScheduledPost,
    childViewContainer: "ul",
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