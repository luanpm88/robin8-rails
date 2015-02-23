Robin.module("Analytics", function(Analytics, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    showAnalyticsPage: function() {
      Analytics.Show.Controller.showAnalyticsPage();
    }
  }

  Analytics.on('start', function(){
    API.showAnalyticsPage();
    $('#nav-analytics').parent().addClass('active');
  })

  Analytics.on("stop", function(){
    this.Show.Controller.layout.destroy();
  });
  
});