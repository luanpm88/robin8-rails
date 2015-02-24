Robin.Controllers.AppController = Marionette.Controller.extend({
  initialize: function (options) {
    this.stopAll();
    Robin.module('Navigation').start();
    Robin.module('Dashboard').start();
    Robin.module('SaySomething').start();
  },
  showDashboard: function() {
    this.stopAll();
    Robin.module('Dashboard').start();
  },

  showRobin: function() {
    this.stopAll();
    Robin.module('ReleasesBlast').start();
  },

  showMonitoring: function() {
    this.stopAll();
    Robin.module('Monitoring').start();
  },

  showNewsRooms: function() {
    this.stopAll();
    Robin.module("Newsroom").start();
    // Backbone.history.navigate('news_rooms',{trigger:true});
    // Robin.module("Newsroom").controller.index();
  },

  showReleases: function() {
    this.stopAll();
    Robin.module("Releases").start();
  },

  showSocial: function() {
    this.stopAll();
    Robin.module('Social').start();
  },

  showAnalytics: function() {
    this.stopAll();
    Robin.module('Analytics').start();
  },

  showProfile: function() {
    this.stopAll();
    Robin.module('Profile').start();
  },

  stopAll: function(){
    var routesCount = Robin.routesCount;
    if (Backbone.history.handlers.length > routesCount){
        var arr = Backbone.history.handlers.reverse();
        arr.splice(routesCount, Backbone.history.handlers.length - routesCount);
        Backbone.history.handlers = arr.reverse();
    }
    Robin.stopOtherModules();
  }
});
