Robin.Models.UserRegistration = Backbone.Model.extend({
  url: '/users.json',

  defaults: {
    "email": "",
    "password": "",
    "password_confirmation": ""
  }
});