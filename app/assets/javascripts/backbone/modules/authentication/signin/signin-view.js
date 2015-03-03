Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.SignInView = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/signin',

    events: {
      'click #login' : 'login',
      'click .btn-facebook' : 'socialSignIn',
      'click .btn-google-plus' : 'socialSignIn',
    },

    initialize: function() {
      this.model = new Robin.Models.UserSession();
      this.modelBinder = new Backbone.ModelBinder();
    },

    onRender: function() {
      this.modelBinder.bind(this.model, this.el);
    },

    login: function(e) {
      e.preventDefault();

      el = $(this.el);

      this.modelBinder.copyViewValuesToModel();
      
      this.model.save(this.model.attributes, {
        success: function(data, response, jqXHR){
          var token = jqXHR.xhr.getResponseHeader('X-CSRF-Token');
          if (token) {
            $("meta[name='csrf-token']").attr('content', token);
            Robin.finishSignIn(response);
            window.history.pushState('', '', '/');
          }
        },
        error: function(userSession, response) {
          var result = $.parseJSON(response.responseText);
          this.$('#alert-danger').show();
          this.$('#alert-danger').text(result.error);
        }
      });
    },   

  });
});