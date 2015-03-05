Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.ForgotView = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/forgot',

    events: {
    'click #send': 'retrievePassword',
    'keyup #email' : 'removeAlert',
    },

    initialize: function() {
    this.model = new Robin.Models.UserPasswordRecovery();
    this.modelBinder = new Backbone.ModelBinder();
    },

    onRender: function() {
      this.modelBinder.bind(this.model, this.el);
    },

    retrievePassword: function(e) {
      var self = this,
      el = $(this.el);
      e.preventDefault();
      el.find('input.btn-primary').button('loading');

      this.model.save(this.model.attributes, {
        success: function(userSession, response) {
          window.location = '#signin'
          $.growl({message: 'An email with password reset information has been sent'
          },{
            type: 'success'
          });
        },
        error: function(userSession, response) {
          this.$('.alert').show();
        }
      });
    },

    removeAlert: function() {
      this.$('.alert').hide();
    },

  });

});
