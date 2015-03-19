Robin.module('Dashboard.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.DashboardPage = Backbone.Marionette.LayoutView.extend({
    template: 'modules/dashboard/show/templates/dashboard',
    events: {
      'click #stream': 'addStream',
      'click #newsroom': 'addNewsroom',
      'click #release': 'addRelease',
      'click #smart-release': 'addSmartRelease'
    },

    addStream: function(){
      Robin.newStreamFromDashboard = true;
      Backbone.history.navigate('monitoring', {trigger:true});
    },

    addNewsroom: function(){
      Robin.newNewsroomFromDashboard = true;
      Backbone.history.navigate('news_rooms', {trigger:true});

    },

    addRelease: function(){
      Robin.newReleaseFromDashboard = true;
      Backbone.history.navigate('releases', {trigger:true});
    },

    addSmartRelease: function(){
      Backbone.history.navigate('robin8', {trigger:true});
    },


  });
});