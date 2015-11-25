Robin.Models.CnRecommendation = Backbone.Model.extend(
{
  toJSON: function(){
    var attrs = this.attributes;

    var recommendation = _.extend(attrs, { 
      //timeago: ($.timeago(attrs.published_at)).replace('about',''), 
     });
    return { recommendation: recommendation };
  }
}
);