Robin.Models.Pitch = Backbone.Model.extend({
  urlRoot: '/pitches',

  toJSON: function() {
    var pitch = _.clone( this.attributes );
    return { pitch: pitch };
  },
  
  savePitch: function(data, options) {
    var model = this,
    options = {
      data: { 
        pitch: data
      },
      url: this.urlRoot,
      type: 'POST'
    };
    var success = options.success;
    options.success = function(resp) {
      if (!model.set(model.parse(resp, options), options)) 
        return false;
      
      if (success) 
        success(model, resp, options);
      
      model.trigger('sync', model, resp, options);
    };

    return this.sync('read', this, options);
  }
});
