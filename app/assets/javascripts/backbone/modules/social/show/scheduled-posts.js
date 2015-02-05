Robin.module('Social.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.ScheduledPosts = Backbone.Marionette.ItemView.extend({
    template: 'modules/social/show/templates/scheduled_posts',
  })
});