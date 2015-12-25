Robin.module("Profile", function(Profile, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    showProfilePage: function() {
      Profile.Show.Controller.showProfilePage();
    }
  }

  Profile.on('start', function(){
    API.showProfilePage();
    $('#sidebar-wrapper').show();
    $('#nav-sidebar-profile').parent().addClass('active');
  })

});
