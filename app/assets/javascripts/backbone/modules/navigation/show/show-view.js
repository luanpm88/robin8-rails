Robin.module('Navigation.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.NavigationView = Backbone.Marionette.ItemView.extend({
    getTemplate: function() {
      if (!App.KOL) {
        return 'modules/navigation/show/templates/navigation';
      } else if (App.currentKOL) {
        return 'modules/navigation/show/templates/navigation_kol';
      }
    }
  });

});
