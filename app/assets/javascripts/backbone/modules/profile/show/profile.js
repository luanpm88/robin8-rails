Robin.module('Profile.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.ProfilePage = Backbone.Marionette.LayoutView.extend({
    getTemplate: Robin.template('modules/profile/show/templates/profile'),

    regions: {
      social_profiles: "#social-profiles",
      backend_screen: "#backend_screen"
    },

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
      this.$el.find('#date_of_birthday').datetimepicker({format: 'MM/DD/YYYY', minDate: '01/01/1915', maxDate: new Date()});
      this.$el.find("input[type='checkbox']").iCheck({
        checkboxClass: 'icheckbox_square-blue',
        increaseArea: '20%'
      });
      if (Robin.KOL) {
        var currentView = this;
        $.get( "/users/get_identities", function( data ) {
          App.identities = data;
          var viewProfiles = new App.Social.Show.SocialProfiles({collection: new Robin.Collections.Identities(data)});
          currentView.getRegion('social_profiles').show(viewProfiles);
        });
        var backendScreens = new Show.BackendScreens({model: this.model});
        currentView.getRegion('backend_screen').show(backendScreens);
      }
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
                message: polyglot.t("profile.messages.required_email")
              },
              regexp: {
                regexp: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
                message: 'The data you have entered is not a valid email'
              },
              serverError: {
                message: polyglot.t('profile.something_wrong')
              }
            }
          },
          current_password: {
            enabled: false,
            validators: {
              notEmpty: {
                message: polyglot.t('profile.current_password_req')
              },
              serverError: {
                message: polyglot.t('profile.something_wrong')
              }
            }
          },
          password: {
            enabled: false,
            validators: {
              notEmpty: {
                message: polyglot.t('profile.password_required')
              },
              serverError: {
                message: polyglot.t('profile.something_wrong')
              }
            }
          },
          password_confirmation: {
            enabled: false,
            validators: {
              notEmpty: {
                message: polyglot.t('profile.password_confirmation_req')
              },
              identical: {
                field: 'password',
                message: polyglot.t('profile.password_confirmation_must_same')
              },
              serverError: {
                message: polyglot.t('profile.something_wrong')
              }
            }
          },
          mobile_number: {
            enabled: false,
            validators: {
              notEmpty: {
                message: 'Please enter a value'
              },
              regexp: {
                regexp: /^\d*$/,
                message: 'Digits only'
              },
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
      .on('keyup', '[name="mobile_number"]', function() {
        $('#profileForm').formValidation('enableFieldValidators', 'mobile_number', true)
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
      if ((formChanged || Robin.KOL) && this.$el.find("#profileForm").data('formValidation').isValid()) {
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
            $.growl({message: polyglot.t('profile.account_successfully_changed')
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
    },
  });
  Show.BackendScreens = Backbone.Marionette.ItemView.extend({
    template: 'modules/profile/show/templates/profile_backend_screens',

    events: {
      'click #deleteAttach': 'deleteAttach'
    },

    initialize: function() {
      this.model = this.options.model;
    },

    serializeData: function() {
      return {
        items: this.model.toJSON()
      };
    },

    onRender: function() {
      this.model = this.options.model;
      setTimeout((function(_this) {
        return function() {
          _this.$el.find(".image-preview-multiple-plus .uploadcare-widget-button-open").text("").addClass("fa fa-plus-square");
          _this.weiboFileWidget = uploadcare.MultipleWidget('[id=weiboScreen][role=uploadcare-uploader][data-multiple][data-photo]').onChange(function(fileGroup) {
            if (fileGroup) {
              return $.when.apply(null, fileGroup.files()).done(function() {
                var arr, crop;
                crop = '-/scale_crop/160x160/center/';
                arr = _.clone(_this.model.get('screens') || []);
                _.each(arguments, function(value, key) {
                  if (!_.find(arr, function(item) {
                    return item.url === value.cdnUrl;
                  })) {
                    return arr.push({
                      url: value.cdnUrl,
                      name: value.name,
                      thumbnail: value.cdnUrl + crop,
                      social_name: 'weiboScreenAccount'
                    });
                  }
                }, _this);
                _this.model.set('screens', arr);
                _this.model.save();
                return _this.weiboFileWidget.value(null);
              });
            }
          }, 0);
          _this.weChatFileWidget = uploadcare.MultipleWidget('[id=wechatScreen][role=uploadcare-uploader][data-multiple][data-photo]').onChange(function(fileGroup) {
            if (fileGroup) {
              return $.when.apply(null, fileGroup.files()).done(function() {
                var arr, crop;
                crop = '-/scale_crop/160x160/center/';
                arr = _.clone(_this.model.get('screens') || []);
                _.each(arguments, function(value, key) {
                  if (!_.find(arr, function(item) {
                    return item.url === value.cdnUrl;
                  })) {
                    return arr.push({
                      url: value.cdnUrl,
                      name: value.name,
                      thumbnail: value.cdnUrl + crop,
                      social_name: 'weChatScreenAccount'
                    });
                  }
                }, _this);
                _this.model.set('screens', arr);
                _this.model.save();
                return _this.weChatFileWidget.value(null);
              });
            }
          }, 0);
           _this.$el.find(".image-preview-multiple-plus .uploadcare-widget-button-open").text("").addClass("fa fa-plus-square");
        };
      })(this));
      this.model.on('change', this.render, this);
    },
    deleteAttach: function(e) {
      var arr = [];
      if (this.model.get('screens') && this.model.get('screens').length){
        arr = _.clone(this.model.get('screens'));
      }
      for(var i=0;i<arr.length;i++){
        if(arr[i].url == e.currentTarget.previousElementSibling.href){
          arr.splice(i, 1);
          break;
        }
      }
      this.model.unset('screens');
      this.model.set('screens', arr);
      this.model.save();
    }
  });
});
