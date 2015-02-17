Robin.module("ManageUsers", function(ManageUsers, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    showManageUsersPage: function() {
      ManageUsers.Show.Controller.showManageUsersPage();
    }
  }

  ManageUsers.on('start', function(){
     API.showManageUsersPage();
  })
  
});