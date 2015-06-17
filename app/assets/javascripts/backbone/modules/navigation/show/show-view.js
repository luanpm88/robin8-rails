Robin.module('Navigation.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.NavigationView = Backbone.Marionette.ItemView.extend({
    template: 'modules/navigation/show/templates/navigation',

    // Checks if there are no recommendations and then adds to the nav
    onRender :function(){
        var lastSignInAt = Robin.currentUser.attributes.updated_at;
        var id = Robin.currentUser.attributes.id;
        var statusUrl = "/recommendations/status/" + id + ".json?last_sign_in_at=" + lastSignInAt;
        $.get( statusUrl, function( data ) {
            if(data.new_recommendations > 0) {
                $("#no-new-recommendations").hide();
                $("#new-recommendations-badge").text(data.new_recommendations);
                $("#new-recommendations").show();
            }
        });
    }

    // events: {
    //   'click #nav-dashboard': 'showDashboard',
    //   'click #nav-robin8': 'showRobin',
    //   'click #nav-monitoring': 'showMonitoring',
    //   'click #nav-newsrooms': 'showNewsRooms',
    //   'click #nav-releases': 'showReleases',
    //   'click #nav-social': 'showSocial',
    //   'click #nav-analytics': 'showAnalytics',
    //   'click #nav-sidebar-profile': 'showProfile',
    // },

    // initialize: function() {
    // },

    // showDashboard: function() {
    //   Robin.stopOtherModules();
    //   Robin.module('Dashboard').start();
    // },

    // showRobin: function() {
    //   Robin.stopOtherModules();
    // },

    // showMonitoring: function() {
    //   Robin.stopOtherModules();
    //   Robin.module('Monitoring').start();
    // },

    // showNewsRooms: function() {
    //   Robin.stopOtherModules();
    //   Robin.module("Newsroom").start();
    //   // Backbone.history.navigate('news_rooms',{trigger:true});
    //   // Robin.module("Newsroom").controller.index();
    // },

    // showReleases: function() {
    //   Robin.stopOtherModules();
    //   Robin.module("Releases").start();
    //   Robin.module("Releases").controller.index();
    // },

    // showSocial: function() {
    //   Robin.stopOtherModules();
    //   Robin.module('Social').start();
    // },

    // showAnalytics: function() {
    //   Robin.stopOtherModules();
    // },

    // showProfile: function() {
    //   Robin.stopOtherModules();
    //   Robin.module('Profile').start();
    // }
  });

});