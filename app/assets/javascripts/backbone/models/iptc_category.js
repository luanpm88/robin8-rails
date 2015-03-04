Robin.Models.IptcCategory = Backbone.Model.extend({
  toJSON: function() {
    var iptc_category = _.clone( this.attributes );
    return { iptc_category: iptc_category };
  }
});
