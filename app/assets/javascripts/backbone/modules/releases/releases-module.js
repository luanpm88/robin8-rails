Robin.module("Releases", function(Releases, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    showReleasesPage: function() {
      Releases.Show.Controller.showReleasesPage();
    }
  }

  Releases.on('start', function(){
    API.showReleasesPage();
  })

});