Robin.Models.Post = Backbone.Model.extend({
  url: '/posts.json',
  paramRoot: 'post',

  defaults: {
    "text": "",
    "scheduled_date": ""
  }
});