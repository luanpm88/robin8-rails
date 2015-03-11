Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _) {
  Releases.CharacteristicsView = Marionette.ItemView.extend({
    template: 'modules/releases/templates/characteristics-view',
    modelEvents: {
      'change': 'render'
    }
  });
});
