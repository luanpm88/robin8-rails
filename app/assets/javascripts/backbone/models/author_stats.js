Robin.Models.AuthorStats = Backbone.Model.extend({
  initialize: function(){
    this.url = '/robin8_api/authors/' + this.id  + '/stats';
  }
});
