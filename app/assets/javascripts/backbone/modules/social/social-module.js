Robin.module("Social", function(Social, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    showSocialPage: function() {
      Social.Show.Controller.showSocialPage();
    }
  }

  Social.on('start', function(){
    if (!Robin.KOL) {
      this.generalView = new Social.Show.GeneralPostsView();

      this.postsCollection = new Robin.Collections.Posts();
      this.tomorrowsPostsCollection = new Robin.Collections.TomorrowsPosts();
      this.othersPostsCollection = new Robin.Collections.OtherPosts();

      this.postsView = new Social.Show.TodayPostsComposite({ collection: this.postsCollection });
      this.tomorrowPostsView = new Social.Show.TomorrowPostsComposite({ collection: this.tomorrowsPostsCollection });
      this.othersPostsView = new Social.Show.OthersPostsComposite({ collection: this.othersPostsCollection });
    }
    API.showSocialPage();
    $('#nav-social').parent().addClass('active');
  })

});
