Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){

  Releases.AddButtonView = Marionette.ItemView.extend({
    template: 'modules/releases/templates/add-new-button',
    onRender: function() {
      if(Robin.user.get('can_create_release') != true) {
        $('button#new_release').attr('disabled', 'disabled');
      } else {
        $('button#new_release').removeAttr('disabled');
      }
    }
  });
});
