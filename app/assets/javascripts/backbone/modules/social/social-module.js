Robin.module("Social", function(Social, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    showSocialPage: function() {
      Social.Show.Controller.showSocialPage();
    }
  }

  Social.on('start', function(){
    this.postsCollection = new Robin.Collections.Posts();
    API.showSocialPage();
    $('#nav-social').parent().addClass('active');
  })
  
});