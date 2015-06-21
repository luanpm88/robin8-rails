Robin.module('Navigation.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.NavigationView = Backbone.Marionette.ItemView.extend({
    getTemplate: App.template('modules/navigation/show/templates/navigation')
  });

});
