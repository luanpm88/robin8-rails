Robin.Models.User = Backbone.Model.extend({
  signOut: function(data, options) {    
    var model = this;
    options = {
      url: 'users/sign_out',
      type: 'GET'
    };
    var success = options.success;
    options.success = function(resp) {
      if (!model.set(model.parse(resp, options), options)) return false;
      if (success) success(model, resp, options);
      model.trigger('sync', model, resp, options);
    };

    return this.sync('read', this, options);
  }
});