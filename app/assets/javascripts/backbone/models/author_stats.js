Robin.Models.AuthorStats = Backbone.Model.extend({
  initialize: function(){
    this.url = '/robin8_api/authors/' + this.id  + '/stats';
    
    if (Robin.currentUser.get('locale') == 'zh'){
      this.url += "?type=weibo";
    }
  }
});
