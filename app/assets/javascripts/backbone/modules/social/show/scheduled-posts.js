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
    }
  });
  
  Show.ScheduledPostsComposite = Backbone.Marionette.CompositeView.extend({
    template: "modules/social/show/templates/scheduled_posts",
    childView: Show.ScheduledPost,
    childViewContainer: "ul",
    initialize: function() {
      this.collection.fetch();
    }
  });

});