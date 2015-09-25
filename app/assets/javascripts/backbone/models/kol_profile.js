Robin.Models.KolProfile = Backbone.Model.extend({
  url: '/kols.json',
  paramRoot: 'kol',

  defaults: {
    "email": "",
    "password": "",
    "password_confirmation": ""
  },

  monetize: function(data, options){
    var model = this,
      url = '/kols/monetize',
      options = {
        data: data,
        url: url,
        type: 'POST'
      };

    var success = options.success;
    options.success = function(resp) {
      if (!model.set(model.parse(resp, options), options)) return false;
      if (success) success(model, resp, options);
      model.trigger('sync', model, resp, options);
    };

    return this.sync('read', this, options);
  },
});
