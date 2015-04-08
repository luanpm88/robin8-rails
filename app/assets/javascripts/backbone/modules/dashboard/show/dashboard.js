Robin.module('Dashboard.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.DashboardPage = Backbone.Marionette.LayoutView.extend({
    template: 'modules/dashboard/show/templates/dashboard',
    events: {
      'click #stream': 'addStream',
      'click #newsroom': 'addNewsroom',
      'click #release': 'addRelease',
      'click #smart-release': 'addSmartRelease'
    },

    onRender: function(){
      Robin.user = new Robin.Models.User();
      var curView = this;
      Robin.user.fetch({
        success: function() {
          if (Robin.user.get('can_create_newsroom') != true) {
            curView.$el.find("#newsroom").attr('disabled', 'disabled');
          } else {
            curView.$el.find("#newsroom").removeAttr('disabled');
          }
          if (Robin.user.get('can_create_release') != true) {
            curView.$el.find("#release").attr('disabled', 'disabled');
          } else {
            curView.$el.find("#release").removeAttr('disabled');
          }
          if (Robin.user.get('can_create_smart_release') != true) {
            curView.$el.find("#smart-release").attr('disabled', 'disabled');
          } else {
            curView.$el.find("#smart-release").removeAttr('disabled');
          }
          if (Robin.user.get('can_create_stream') != true) {
            curView.$el.find("#stream").attr('disabled', 'disabled');
          } else {
            curView.$el.find("#stream").removeAttr('disabled');
          }
        }
      });
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