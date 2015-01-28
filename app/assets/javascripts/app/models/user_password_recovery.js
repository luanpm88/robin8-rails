Robin.Models.UserPasswordRecovery = Backbone.Model.extend({
  url: '/users/password.json',

  defaults: {
    "email": ""
  }
});