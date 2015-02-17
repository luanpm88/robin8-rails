Robin.module('ManageUsers.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.Controller = {

    showManageUsersPage: function(){
      var manageUsersPageView = this.getManageUsersPageView();
      Robin.layouts.main.content.show(manageUsersPageView);
    },

    getManageUsersPageView: function(){
       return new Show.ManageUsersPage();
    },
  }

});