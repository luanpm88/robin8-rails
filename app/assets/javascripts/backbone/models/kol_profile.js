Robin.Models.KolProfile = Backbone.Model.extend({
  url: '/kols.json',
  paramRoot: 'kol',

  defaults: {
    "email": "",
    "password": "",
    "password_confirmation": ""
  },

  monetize: function(data, options){

    this.save(data, _.extend(options, {
      url: '/kols/monetize',
    }));

  },
});
