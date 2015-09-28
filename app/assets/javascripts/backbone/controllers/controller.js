Robin.Controllers.AppController = Marionette.Controller.extend({
  initialize: function (options) {
    this.stopAll();
     locale = !Robin.KOL ? Robin.currentUser.get('locale') : "";
    Robin.module('Navigation').start();
    locale = Robin.currentUser.get('locale');
    if (!Robin.KOL) {
      Robin.module('SaySomething').start();
    }
  },
  showDashboard: function() {
    this.stopAll();
    if (!Robin.KOL) {
      Robin.module('Dashboard').start();
    } else {
      Robin.module('DashboardKol').start();
    }
  },

  showRobin: function() {
    this.stopAll();
    Robin.module('ReleasesBlast').start();
  },

  showManageUsers: function() {
    this.stopAll();
    if (Robin.currentUser.attributes.is_primary != false) {
      Robin.module('ManageUsers').start();
    } else {
      Backbone.history.navigate('dashboard', {trigger:true});
    }
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

  showSmartCampaign: function() {
    this.stopAll();
    Robin.module("SmartCampaign").start();
  },

  showReleases: function() {
    this.stopAll();
    Robin.module("Releases").start();
  },

  showSocial: function() {
    this.stopAll();
    Robin.module('Social').start();
  },

  showBilling: function() {
    this.stopAll();
    Robin.module('Billing').start();
  },

  showAnalytics: function() {
    this.stopAll();
    Robin.module('Analytics').start();
  },

  showEmailsAnalytics: function() {
    this.stopAll();
    Robin.module('Analytics').start();
  },

  showCampaignAnalytics: function() {
    this.stopAll();
    Robin.module('Analytics').start();
  },

  showProfile: function() {
    this.stopAll();
    Robin.module('Profile').start();
  },

  showWeChatAnalytics: function() {
    this.stopAll();
    Robin.module('Analytics').start();
  },

  showWeiboAnalytics: function() {
    this.stopAll();
    Robin.module('Analytics').start();
  },

  showRecommendations: function() {
    this.stopAll();
    Robin.module('Recommendations').start();
  },

  showCampaigns: function(){
    this.stopAll();
    Robin.module('Campaigns').start();
  },

  showCampaignsList: function(){
    this.stopAll();
    Robin.module('CampaignsList').start();
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
