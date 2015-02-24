Robin.Models.Attachment = Backbone.Model.extend({
  toJSON: function() {
      var attachment = _.clone( this.attributes );
      return { attachment: attachment };
  }
});