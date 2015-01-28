Robin.Models.UserSession = Backbone.Model.extend({
  url: '/users/sign_in.json',

  defaults: {
    "email": "",
    "password": ""
  }

});