Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.ResetView = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/reset',

    events: {
      'submit form' : 'submit',
      'keyup #password' : 'removeAlert',
      'keyup #password_confirmation' : 'removeAlert',
    },

    initialize: function(options) {
      this.model = new Robin.Models.UserPasswordRecovery();
      this.modelBinder = new Backbone.ModelBinder();
      this.model.attributes.reset_password_token = options.resetToken;
    },

    onRender: function() {
      this.modelBinder.bind(this.model, this.el);
    },

    submit: function(e) {
      e.preventDefault();
      el = $(this.el);

      this.modelBinder.copyViewValuesToModel();

      var pass = this.model.attributes.password;
      var confirm = this.model.attributes.password_confirmation;
      var token = this.model.attributes.reset_password_token;
      var that = this;

      $.post("/users/password.json", { _method:'PUT', autocomplete:"off", utf8: "&#x2713;", user:{reset_password_token: token, password: pass, password_confirmation: confirm}})
        .done(function(response) {
          $.get( "/users/get_current_user", function( data ) {
            if (data != undefined) {
              Robin.finishSignIn(data);
            }
          });
        })
        .fail(function(response) {
          var result = $.parseJSON(response.responseText);
          var message = "";
          _(result.errors).each(function(errors,field) {
            $('input[name=' + field + ']').addClass('error');
            _(errors).each(function(error, i) {
              formatted_field = s(field).capitalize().value().replace('_', ' ');
              message += (formatted_field + ' ' + error + '<br>');
            });
          });
          console.log(message);
          that.$('#alert-danger').show();
          that.$('#alert-danger').html(message);
        });
    },

    removeAlert: function() {
      this.$('.alert').hide();
    },

  });
});