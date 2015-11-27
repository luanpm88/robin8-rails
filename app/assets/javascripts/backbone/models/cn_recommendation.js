Robin.Models.CnRecommendation = Backbone.Model.extend(
{
  toJSON: function(){
    var attrs = this.attributes;

    var recommendation = _.extend(attrs, {
      image_name: "recommendations/" + attrs.label +  Math.floor((Math.random()*3)+1) +".png"
      //timeago: ($.timeago(attrs.published_at)).replace('about',''),
     });
    return { recommendation: recommendation };
  }
}
);
