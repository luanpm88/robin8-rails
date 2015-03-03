Robin.module('AuthenticationOld.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.SignUpView = Backbone.Marionette.ItemView.extend( {
    template: 'modules/authentication/signin/templates/signup',

    events: {
      'click #register' : 'signup',
      'click .btn-facebook' : 'socialSignIn',
      'click .btn-google-plus' : 'socialSignIn',
    },

    initialize: function() {
      this.model = new Robin.Models.UserRegistration();
      this.modelBinder = new Backbone.ModelBinder();
    },

    onRender: function() {
      this.modelBinder.bind(this.model, this.el);
    },

    onShow: function() {
      this.initFormValidation();
    },

    initFormValidation: function(){
      this.form = $('#formSignup').formValidation({
        framework: 'bootstrap',
        excluded: [':disabled'],
        icon: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
          email: {
            validators: {
              notEmpty: {
                message: 'The email address is required'
              },
              regexp: {
                regexp: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
                message: 'The data you have entered is not a valid email'
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          },
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

    signup: function(e) {
      e.preventDefault();
      var viewObj = this;
      this.form.data('formValidation').validate();
      if (this.form.data('formValidation').isValid()) {
        this.model.save(this.model.attributes, {
          success: function(userSession, response) {
            Robin.currentUser = new Robin.Models.User(response);
            window.location = '#signin'
            $.growl('You will receive an email with instructions for how to confirm your email address in a few minutes', {
              type: "info",
            });
          },
          error: function(data, response) {
            viewObj.processErrors(response);
          }
        });
      }
    },

    processErrors: function(data){
      var errors = JSON.parse(data.responseText).errors;
      _.each(errors, function(value, key){
        this.form.data('formValidation').updateStatus(key, 'INVALID', 'serverError')
        var val = value.join(',');
        if (val === "has already been taken") {
          val = "This email " + val;
        }
        this.form.data('formValidation').updateMessage(key, 'serverError', val)
      }, this);
    },

    socialSignIn: function(e) {
      e.preventDefault();
      var currentView = this;
      
      if ($(e.target).children().length != 0) {
        var provider = $(e.target).attr('id');
      } else {
        var provider = $(e.target).parent().attr('id');
      };

      var url = '/users/auth/' + provider,
      params = 'location=0,status=0,width=800,height=600';
      currentView.connect_window = window.open(url, "connect_window", params);

      currentView.interval = window.setInterval((function() {
        if (currentView.connect_window.closed) {
          $.get( "/users/get_current_user", function( data ) {
            window.clearInterval(currentView.interval);
            if (data != undefined) {
              Robin.finishSignIn(data);
            } 
          });
        }
      }), 500);
    }
  });
});

Robin