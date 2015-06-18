Robin.Models.UserSession = Backbone.Model.extend({
  url: '/users/sign_in.json',
  paramRoot: 'user',

  defaults: {
    "email": "",
    "password": ""
  }

});


Robin.Models.KOLSession = Robin.Models.UserSession.extend({
  url: '/kols/sign_in.json',
  paramRoot: 'kol',
});

