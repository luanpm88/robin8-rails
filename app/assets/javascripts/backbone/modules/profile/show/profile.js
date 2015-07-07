Robin.module('Profile.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.ProfilePage = Backbone.Marionette.LayoutView.extend({
    getTemplate: Robin.template('modules/profile/show/templates/profile'),

    events: {
      'click #saveChanges': 'updateProfile'
    },

    initialize: function() {
      if (!Robin.KOL) {
        this.model = new Robin.Models.UserProfile(Robin.currentUser.attributes);
        this.tempUser = new Robin.Models.UserProfile(Robin.currentUser.attributes);
      } else {
        this.model = new Robin.Models.KolProfile(Robin.currentKOL.attributes);
        this.tempUser = new Robin.Models.KolProfile(Robin.currentKOL.attributes);
      }
      this.modelBinder = new Backbone.ModelBinder();
    },

    onRender: function() {
      this.modelBinder.bind(this.model, this.el);
      this.$el.find("input[type='checkbox']").iCheck({
        checkboxClass: 'icheckbox_square-blue',
        increaseArea: '20%'
      });
    },

    onShow: function() {
      this.initFormValidation();

      if (Robin.KOL) {
        var autocomplete = new google.maps.places.Autocomplete($("#location")[0], {});

        $('#interests').select2({
          placeholder: "Select your interests",
          multiple: true,
          minimumInputLength: 1,
          maximumSelectionSize: 10,
          ajax: {
            url: "/kols/suggest_categories",
            dataType: 'json',
            quietMillis: 250,
            data: function (term) {
              return {
                f: term // search term
              };
            },
            results: function (data) {
              return {
                results: data
              };
            },
            cache: true
          },
          escapeMarkup: function (m) { return m; },
          initSelection: function(el, callback) {
            $("#interests").val('');
            $.get("/kols/current_categories", function(data) {
              callback(data);
            });
          }
        });
      } else {
        if (this.model.attributes.avatar_url) {
          $("#avatar-image").attr('src', this.model.attributes.avatar_url);
        }
        var viewObj = this;
        this.widget = uploadcare.Widget('[role=uploadcare-uploader]').onUploadComplete(function(info){
          $("#avatar-image").attr('src', info.cdnUrl);
          viewObj.model.set({avatar_url: info.cdnUrl});
        });
        this.widget.validators.push(this.maxFileSize(3145728));
        if (Robin.afterConfirmationMessage != undefined) {
          $.growl(Robin.afterConfirmationMessage,{
            offset: 65,
            delay: 5000,
            placement: {
              from: "top",
              align: "right"
            },
            type: 'success'
          });
          Robin.afterConfirmationMessage = undefined
        }
      }
    },

    maxFileSize: function(size) {
      return function(fileInfo) {
        if (fileInfo.size !== null && fileInfo.size > size) {
          throw new Error("fileMaximumSize");
        };
      };
    },

    initFormValidation: function(){
      var view = this;
      this.form = $('#profileForm').formValidation({
        framework: 'bootstrap',
        excluded: [':disabled'],
        icon: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
          email: {
            enabled: false,
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
          current_password: {
            enabled: false,
            validators: {
              notEmpty: {
                message: 'Current password is required in order to set a new one'
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          },
          password: {
            enabled: false,
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
            enabled: false,
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
      .on('keyup', '[name="password"]', function() {
        var isEmpty = $(this).val() == '';
        $('#profileForm')
          .formValidation('enableFieldValidators', 'current_password', !isEmpty)
          .formValidation('enableFieldValidators', 'password', !isEmpty)
          .formValidation('enableFieldValidators', 'password_confirmation', !isEmpty);
        // Revalidate the field when user starts typing in the password field
        if ($(this).val().length == 1) {
          $('#profileForm').formValidation('validateField', 'current_password')
                          .formValidation('validateField', 'password')
                          .formValidation('validateField', 'password_confirmation');
        }
      })
      .on('keydown', '[name="email"]', function() {
        $('#profileForm').formValidation('enableFieldValidators', 'email', true)
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
        $(currentPassword).removeClass('has-feedback').removeClass('has-success');
        $(currentPassword).find("i").hide();
      });
    },

    updateProfile: function() {
      var viewObj = this;
      initialAttributes = this.tempUser.attributes;
      currentAttributes = this.model.attributes;
      emailChanged = (initialAttributes.email != currentAttributes.email);
      formChanged = (JSON.stringify(initialAttributes) != JSON.stringify(currentAttributes));
      if ((formChanged || Robin.KOL) && this.form.data('formValidation').isValid()) {
        this.modelBinder.copyViewValuesToModel();
        if (Robin.KOL) {
          this.model.set({"interests": $("#interests").val()});
        }
        this.model.save(this.model.attributes, {
          success: function(userSession, response) {
            if (!Robin.KOL) {
              Robin.currentUser.attributes = currentAttributes;
              Robin.currentUser.attributes.current_password = "";
            } else {
              Robin.currentKOL.attributes = currentAttributes;
              Robin.currentKOL.attributes.current_password = "";
            }

            Robin.layouts.main.onShow();
            $.growl({message: 'Your account data has been successfully changed'
            },{
              element: '#growler-alert',
              type: 'success',
              offset: 65,
              delay: 3500,
              placement: {
                from: "top",
                align: "right"
              },
            });
          },
          error: function(userSession, response) {
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
        if (val === "is invalid") {
          val = "Current password " + val;
        }
        this.form.data('formValidation').updateMessage(key, 'serverError', val)
      }, this);
    }

  });
});
