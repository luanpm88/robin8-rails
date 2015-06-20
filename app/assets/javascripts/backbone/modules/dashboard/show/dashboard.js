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
            curView.$el.find("#newsroom").addClass('disabled-unavailable');
          } else {
            curView.$el.find("#newsroom").removeClass('disabled-unavailable');
          }
          if (Robin.user.get('can_create_release') != true) {
            curView.$el.find("#release").addClass('disabled-unavailable');
          } else {
            curView.$el.find("#release").removeClass('disabled-unavailable');
          }
          if (Robin.user.get('can_create_smart_release') != true) {
            curView.$el.find("#smart-release").addClass('disabled-unavailable');
          } else {
            curView.$el.find("#smart-release").removeClass('disabled-unavailable');
          }
          if (Robin.user.get('can_create_stream') != true) {
            curView.$el.find("#stream").addClass('disabled-unavailable');
          } else {
            curView.$el.find("#stream").removeClass('disabled-unavailable');
          }
        }
      });
    },

    addStream: function(){
      if (Robin.user.get('can_create_stream') != true) {
        $.growl({message: "You don't have available streams!"},
          {
            type: 'info'
          });
      } else {
        Robin.newStreamFromDashboard = true;
        Backbone.history.navigate('monitoring', {trigger:true});
      }
    },

    addNewsroom: function(){
      if (Robin.user.get('can_create_newsroom') != true) {
        $.growl({message: "You don't have available newsrooms!"},
          {
            type: 'info'
          });
      } else {
        Robin.newNewsroomFromDashboard = true;
        Backbone.history.navigate('news_rooms', {trigger:true});
      }
    },

    addRelease: function(){
      if (Robin.user.get('can_create_release') != true) {
        $.growl({message: "You don't have available releases!"},
          {
            type: 'info'
          });
      } else {
        Robin.newReleaseFromDashboard = true;
        Backbone.history.navigate('releases', {trigger:true});
      }
    },

    addSmartRelease: function(){
      if (Robin.user.get('can_create_smart_release') != true) {
        $.growl({message: "You don't have available smart-releases!"},
          {
            type: 'info'
          });
      } else {
        Backbone.history.navigate('robin8', {trigger:true});
      }
    },


  });
});
