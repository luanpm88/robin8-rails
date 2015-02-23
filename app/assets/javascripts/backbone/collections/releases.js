Robin.Collections.Releases = Backbone.Collection.extend({
  model: Robin.Models.Release,
  url: '/releases.json',
  parseSortParams: function(options){
    var paramsStr = "";
    _.each(options, function(k,v){
      if (k !== "")
        paramsStr += "&" + v + "=" + k;
    });
    if (paramsStr.length > 0){
      return this.url + '?' + paramsStr;
    } else{
      return this.url;
    }
  },
  filter: function(options){
    this.fetch({
      url: this.parseSortParams(options.params),
      success: options.success
    });
  },
  initialize: function (models,options) {
    this.options = options;
  }
});