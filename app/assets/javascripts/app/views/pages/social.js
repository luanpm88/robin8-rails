Robin.Views.Social = Backbone.Marionette.ItemView.extend({
  template: JST['pages/social'],

  events: {
    'click .btn-facebook': 'connectFacebook',
  },

  // need change 
  templateHelpers: function(){
    return {
      identities: function(){ 
        $.get( "/users/identities", function( data ) {
          return data;
        });
      }
    }
  },

  initialize: function() {
    $.get( "/users/identities", function( data ) {
      return data;
    });
  },

  connectFacebook: function() {
    console.log('connectFacebook');
  }
});