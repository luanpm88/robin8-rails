Robin.module('Social.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.ScheduledPosts = Backbone.Marionette.ItemView.extend({
    template: JST['pages/social/scheduled_posts'],
  })
});