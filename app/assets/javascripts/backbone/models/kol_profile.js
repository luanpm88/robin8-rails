Robin.Models.KolProfile = Backbone.Model.extend({
  url: '/kols.json',
  paramRoot: 'kol',

  defaults: {
    "email": "",
    "password": "",
    "password_confirmation": ""
  }
});