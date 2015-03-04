Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.ResetView = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/reset',

    events: {
      'click #login' : 'login',
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

    onShow: function() {
      this.initFormValidation();
    },

    initFormValidation: function(){
      this.form = $('#formReset').formValidation({
        framework: 'bootstrap',
        excluded: [':disabled'],
        icon: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
          password: {
            validators: {
              notEmpty: {
                message: 'The password is required'
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          },
          password_confirmation: {
            validators: {
              notEmpty: {
                message: 'The password confirmation is required'
              },
              identical: {
                field: 'password',
                message: 'The password confirmation must be the same as original one'
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          },
        }
      })
      .on('err.field.fv', function(e, data) {
        // data.element --> The field element
        var $tabPane = data.element.parents('.tab-pane'),
          tabId    = $tabPane.attr('id');
        $('a[href="#' + tabId + '"][data-toggle="tab"]')
          .addClass('error-tab');
      })
        // Called when a field is valid
      .on('success.field.fv', function(e, data) {
          // data.fv      --> The FormValidation instance
          // data.element --> The field element
        var $tabPane = data.element.parents('.tab-pane'),
          tabId    = $tabPane.attr('id');
        $('a[href="#' + tabId + '"][data-toggle="tab"]')
          .removeClass('error-tab');
      });
    },

    login: function() {
      console.log('sdfsdfsdf');
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