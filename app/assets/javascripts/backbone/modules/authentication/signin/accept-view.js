Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.AcceptView = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/accept',

    events: {
      'submit form' : 'submit',
    },

    initialize: function(options) {
      this.model = new Robin.Models.UserInvitation();
      this.modelBinder = new Backbone.ModelBinder();
      this.model.attributes.invitation_token = options.acceptToken;
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
      var token = this.model.attributes.invitation_token;

      $.post("/users/invitation.json", { _method:'PUT', utf8: "&#x2713;", user:{invitation_token: token, password: pass, password_confirmation: confirm}})
          .done(function(userSession, response) {
            $.get( "/users/get_current_user", function( data ) {
              if (data != undefined) {
                Robin.finishSignIn(data);
              }
            });
          })
          .fail(function(response) {
            var result = $.parseJSON(response.responseText);
            _(result.errors).each(function(errors,field) {
              $('input[name=' + field + ']').addClass('error');
              _(errors).each(function(error, i) {
                formatted_field = s(field).capitalize().value().replace('_', ' ');
                $.growl(formatted_field + ' ' + error, {
                  type: "danger",
                });
            });
        });
      });
    },
  });
});