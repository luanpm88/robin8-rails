var Robin = new Backbone.Marionette.Application();
Robin.Views = {};
Robin.Views.Layouts = {};
Robin.Collections = {};
Robin.Models = {};
Robin.Routers = {};
Robin.Controllers = {};
Robin.cachedStories = {};

Robin.layouts = {};

Robin.loadingStreams = [];

Robin.addRegions({
  main: '#main',
  modal: ModalRegion
});

Robin.setUrl = function(route, options){
  options || (options = {});
  Backbone.history.navigate(route, {trigger: true, replace: true});
};

Robin.template = function(t) {
  return function() {
    if (!Robin.KOL) {
      return t;
    } else {
      return t + "_kol";
    }
  }
};

Robin.finishSignIn = function(data){
  // Robin.currentUser = new Robin.Models.User(data);
  // Robin.vent.trigger("authentication:logged_in");
  // Robin.loadPleaseWait();
  // $('body').removeClass('login');
  // window.history.pushState('', '', '/');
  location.href='/'
};

Robin.loadPleaseWait = function(){
  if (Robin.showLoading) {
    window.loading_screen = window.pleaseWait({
      logo: AppAssets.path('logo.png'),
      backgroundColor: '#3c9eb6',
      loadingHtml: '<p class="loading-message">Just preparing the awesome!</p><div class="sk-spinner sk-spinner-wandering-cubes"><div class="sk-cube1"></div><div class="sk-cube2"></div></div>'
    });
    setTimeout(function(){
      loading_screen.finish();
    }, 1500)
  }
};

Robin.setIdentities = function(data){
  Robin.identities = {};
  Robin.identities.twitter = _.where(data, {provider: "twitter"})[0];
  Robin.identities.facebook = _.where(data, {provider: "facebook"})[0];
  Robin.identities.google = _.where(data, {provider: "google_oauth2"})[0];
  Robin.identities.linkedin = _.where(data, {provider: "linkedin"})[0];
  Robin.identities.weibo = _.where(data, {provider: "weibo"})[0];
  Robin.identities.wechat = _.where(data, {provider: "wechat"})[0];
};

Robin.stopOtherModules = function(){
  _.each(['Newsroom', 'Social', 'Profile', 'Monitoring', 'Dashboard', 'DashboardKol', 'SmartCampaign',
      'Releases', 'ReleasesBlast', 'Analytics', 'Authentication',
      'Billing', 'Recommendations', 'Campaigns'], function(module){
    Robin.module(module).stop();
  });
  $('#sidebar li.active, #sidebar-bottom li.active').removeClass('active');
};

Robin.stopMainModules = function(){
  _.each(['Navigation', 'Dashboard', 'DashboardKol', 'SaySomething'], function(module){
    Robin.module(module).stop();
  });
};

Robin.on('start', function(){
  if (Backbone.history && !Backbone.History.started){
    Robin.addInitializer();
    Backbone.history.start();
    if (Robin.currentUser || Robin.currentKOL) {
      Robin.loadPleaseWait();
    } else {
      if (Robin.afterConfirmationMessage != undefined) {
        $.growl(Robin.afterConfirmationMessage,{
          type: 'success'
        });
        Robin.afterConfirmationMessage = undefined
      }
    };
  }
});

Robin.vent.on("authentication:logged_in", function() {
  if (Robin.publicPages) {
    Robin.layouts.main = new Robin.Views.Layouts.PublicPages();
    Robin.main.show(Robin.layouts.main);
    Robin.stopOtherModules();
    Robin.module('NewsRoomPublic').start();
  } else {
    Robin.layouts.main = new Robin.Views.Layouts.Main();
    Robin.main.show(Robin.layouts.main);
    Backbone.history.handlers = [];
    new Robin.Routers.AppRouter({controller: new Robin.Controllers.AppController()});
  }

});

Robin.vent.on("authentication:logged_out", function() {
  if (Robin.publicPages) {
    Robin.layouts.main = new Robin.Views.Layouts.PublicPages();
    Robin.main.show(Robin.layouts.main);
    Robin.stopOtherModules();
    Robin.module('NewsRoomPublic').start();
  } else {
    Robin.layouts.unauthenticated = new Robin.Views.Layouts.Unauthenticated();
    Robin.main.show(Robin.layouts.unauthenticated);
    Robin.stopMainModules();
    Robin.module('Authentication').start();
  }
});

Robin.bind("before:start", function() {
  Robin.KOL = Robin.currentKOL != null;
  if(Robin.currentUser || Robin.currentKOL) {
    Robin.vent.trigger("authentication:logged_in");
  }
  else {
    Robin.vent.trigger("authentication:logged_out");
  }
});

Robin.vent.on('SaySomething:close', function(){
  console.log('SaySomething:close triggered');
})

//Uploadcare params:
//UPLOADCARE_PUBLIC_KEY = "eaef90e4420402169d1f"
UPLOADCARE_PUBLIC_KEY = "fe688dbff8d2a632a256"
UPLOADCARE_AUTOSTORE = false;
UPLOADCARE_LOCALE_TRANSLATIONS = {
  // messages for widget
  errors: {
    'fileType': 'This type of files is not allowed.',
    'fileMaximumSize': 'File is too large'
  },
  // messages for dialog's error page
  dialog: { tabs: { preview: { error: {
    'fileType': {
      title: 'Title.',
      text: 'Text.',
      back: 'Back'
    },
    'fileMaximumSize': {
      title: 'Selected file is too large!',
      text: 'Maximum image size is 3 MB, please choose another one',
      back: 'Back'
    }
  } } } }
};

if (!Date.prototype.toLocaleFormat) {
  (function() {
    Date.prototype.toLocaleFormat = function(formatString) {
      return this.format(formatString);
    };
  }());
}

