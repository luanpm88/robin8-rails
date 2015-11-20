Robin.Models.CnRecommendation = Backbone.Model.extend(
{
  toJSON: function(){
    var attrs = this.attributes;

    var recommendation = _.extend(attrs, { 
      timeago: ($.timeago(attrs.published_at)).replace('about',''), 
      image: _.first(attrs.images),
      title: attrs.title.replace(/^(.{80}[^\s]*).*/, "$1")
     });
    return { recommendation: recommendation };
  }
}
);