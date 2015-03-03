var Robin = new Backbone.Marionette.Application();
Robin.Views = {};
Robin.Views.Layouts = {};
Robin.Collections = {};
Robin.Models = {};
Robin.Routers = {};
Robin.Controllers = {};
Robin.cachedStories = {};

Robin.layouts = {};

Robin.addRegions({
  main: '#main',
  modal: ModalRegion
});

Robin.setUrl = function(route, options){
  options || (options = {});
  Backbone.history.navigate(route, {trigger: true, replace: true});
};

Robin.finishSignIn = function(data){
  Robin.currentUser = new Robin.Models.User(data);
  Robin.vent.trigger("authentication:logged_in");
  Robin.loadPleaseWait();
  $('#main').removeClass('login');
  Robin.setUrl('/#dashboard');
};

Robin.loadPleaseWait = function(){
  if (Robin.showLoading) {
    window.loading_screen = window.pleaseWait({
      logo: AppAssets.path('logo.png'),
      backgroundColor: 'rgb(81, 119, 155)',
      loadingHtml: '<p class="loading-message">Just preparing the awesome!</p><div class="sk-spinner sk-spinner-wandering-cubes"><div class="sk-cube1"></div><div class="sk-cube2"></div></div>'
    });
    setTimeout(function(){
      loading_screen.finish();
    }, 1500)
  }
};

Robin.setIdentities = function(data){
  Robin.identities = {}
  Robin.identities.twitter = _.where(data, {provider: "twitter"})[0];
  Robin.identities.facebook = _.where(data, {provider: "facebook"})[0];
  Robin.identities.google = _.where(data, {provider: "google_oauth2"})[0];
  Robin.identities.linkedin = _.where(data, {provider: "linkedin"})[0];
};

Robin.stopOtherModules = function(){
  _.each(['Newsroom', 'Social', 'Profile', 'Monitoring', 'Dashboard', 'Releases', 'ReleasesBlast', 'Analytics', 'Authentication'], function(module){
    Robin.module(module).stop();
  });
  $('#sidebar li.active, #sidebar-bottom li.active').removeClass('active');
};

Robin.stopMainModules = function(){
  _.each(['Navigation', 'Dashboard', 'SaySomething'], function(module){
    Robin.module(module).stop();
  });
};

Robin.on('start', function(){
  if (Backbone.history && !Backbone.History.started){
    Robin.addInitializer();
    Backbone.history.start();
    if (Robin.currentUser) {
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
  if(Robin.currentUser) {
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
UPLOADCARE_PUBLIC_KEY = "eaef90e4420402169d1f"
UPLOADCARE_AUTOSTORE = true;
UPLOADCARE_LOCALE_TRANSLATIONS = {
  // messages for widget
  errors: {
    'fileType': 'This type of files is not allowed.'
  },
  // messages for dialog's error page
  dialog: { tabs: { preview: { error: {
    'fileType': {  
      title: 'Title.',
      text: 'Text.',
      back: 'Back'
    }
  } } } }
};
//The UPLOADCARE_PUBLIC_KEY should be changed as soon as paid
// account is avaialble. example:
//UPLOADCARE_PUBLIC_KEY = "a51f0572e52df821db41";

//Filepicker key here:
filepicker.setKey("AqjCqgTScSa65fXp8iGAgz");
