Robin.Models.Industry = Backbone.Model.extend({
  urlRoot: '/industries/',
  toJSON: function() {
      var industry = _.clone( this.attributes );
      return { industry: industry };
  }
});