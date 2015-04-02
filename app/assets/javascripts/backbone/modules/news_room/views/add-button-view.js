Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.AddButtonView = Marionette.ItemView.extend({
    template: 'modules/news_room/templates/add-new-button',
    onRender: function() {
      if(Robin.user.get('can_create_newsroom') != true) {
        $('button#new_newsroom').attr('disabled', 'disabled');
      } else {
        $('button#new_newsroom').removeAttr('disabled');
      }
    }
  });
});
