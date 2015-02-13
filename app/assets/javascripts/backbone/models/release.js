Robin.Models.Release = Backbone.Model.extend({
  urlRoot: '/posts/',
  paramRoot: 'release',

  defaults: {
    "text": "",
    "scheduled_date": "",
    "social_networks": {}
  },

  fetch: function(){
    var model = this;
    model.set({yourStatic: "Json Here"});
  }
});