Robin.Models.Payment = Backbone.Model.extend({
  toJSON: function() {
    var payment = _.clone( this.attributes );
    return { payment: payment };
  }
});
