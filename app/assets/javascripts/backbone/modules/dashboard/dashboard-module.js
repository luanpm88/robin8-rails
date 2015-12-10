Robin.module("Dashboard", function(Dashboard, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  var API = {
    showDashboardPage: function() {
      Dashboard.Show.Controller.showDashboardPage();
    }
  };

  Dashboard.on('start', function(){
    API.showDashboardPage();
    $('#sidebar-wrapper').show();
    $('#nav-dashboard').parent().addClass('active');
  })
});