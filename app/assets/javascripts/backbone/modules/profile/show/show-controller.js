Robin.module('Profile.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.Controller = {

    showProfilePage: function(){
      var profilePageView = this.getProfilePageView();
      Robin.layouts.main.content.show(profilePageView);
    },

    getProfilePageView: function(){
      return new Show.ProfilePage();
    },
  }

});
