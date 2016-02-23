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
      //this.$el.find("input[type='checkbox']").iCheck({
      //  checkboxClass: 'icheckbox_square-blue',
      //  increaseArea: '20%'
      //});
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
          placeholder: polyglot.t('profile.select_interests'),
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

        var uploader = Qiniu.uploader({
          runtimes: 'html5,flash,html4',    //上传模式,依次退化
          browse_button: 'pickfiles',       //上传选择的点选按钮，**必需**
          uptoken_url: "/users/qiniu_uptoken",
              //Ajax请求upToken的Url，**强烈建议设置**（服务端提供）
              //若未指定uptoken_url,则必须指定 uptoken ,uptoken由其他程序生成
          unique_names: true,
              // 默认 false，key为文件名。若开启该选项，SDK会为每个文件自动生成key（文件名）
          // save_key: true,
              // 默认 false。若在服务端生成uptoken的上传策略中指定了 `sava_key`，则开启，SDK在前端将不对key进行任何处理
          domain: '7xozqe.com1.z0.glb.clouddn.com',
              //bucket 域名，下载资源时用到，**必需**
          container: 'container',           //上传区域DOM ID，默认是browser_button的父元素，
          max_file_size: '100mb',           //最大文件体积限制
          flash_swf_url: 'js/plupload/Moxie.swf',  //引入flash,相对路径
          max_retries: 3,                   //上传失败最大重试次数
          dragdrop: true,                   //开启可拖曳上传
          drop_element: 'container',        //拖曳上传区域元素的ID，拖曳文件或文件夹后可触发上传
          chunk_size: '4mb',                //分块上传时，每片的体积
          auto_start: true,                 //选择文件后自动上传，若关闭需要自己绑定事件触发上传

          filters: {
            mime_types : [
              {title : "Image files", extensions: "jpg,jpeg,gif,png"}
            ]
          },

          init: {
              'FilesAdded': function(up, files) {
                  plupload.each(files, function(file) {
                      // 文件添加进队列后,处理相关的事情
                  });
              },
              'BeforeUpload': function(up, file) {
                     // 每个文件上传前,处理相关的事情
              },
              'UploadProgress': function(up, file) {
                     // 每个文件上传时,处理相关的事情
              },
              'FileUploaded': function(up, file, info) {

                var domain = up.getOption('domain');
                var res = jQuery.parseJSON(info);
                var sourceLink = 'http://' + domain + '/' + res.key; //获取上传成功后的文件的Url
                $.ajax({
                  method: "POST",
                  url: "/users/set_avatar_url",
                  beforeSend: function(xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                  },
                  data: {"avatar_url": sourceLink}
                })
                  .done(function(data){
                    $("#avatar-image").attr('src', sourceLink+'-400');
                    Robin.currentUser.set({avatar_url: sourceLink});
                  });

              },
              'Error': function(up, err, errTip) {
                 //上传出错时,处理相关的事情
              },
              'UploadComplete': function() {
                     //队列文件处理完毕后,处理相关的事情
              }
              // 'Key': function(up, file) {
              //     // 若想在前端对每个文件的key进行个性化处理，可以配置该函数
              //     // 该配置必须要在 unique_names: false , save_key: false 时才生效
              //     var key = "";
              //     // do something with key here
              //     return key
              // }
          }
        });
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
                message: polyglot.t('profile.messages.invalid_email')
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
                message: polyglot.t('profile.enter_value')
              },
              regexp: {
                regexp: /^\d*$/,
                message: polyglot.t('profile.digits_only')
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
      if (!formChanged){
        Backbone.history.navigate('#smart_campaign')
        Robin.module("SmartCampaign").start();
      }
      if (this.$el.find("#profileForm").data('formValidation').isValid()) {
        this.modelBinder.copyViewValuesToModel();
        // if (Robin.KOL) {
        //   this.model.set({"interests": $("#interests").val()});
        // }
        this.model.save(this.model.attributes, {
          success: function(userSession, response) {
            if (!Robin.KOL) {
              Robin.currentUser.attributes = currentAttributes;
              Robin.currentUser.attributes.current_password = "";
            } else {
              Robin.currentKOL.attributes = currentAttributes;
              Robin.currentKOL.attributes.current_password = "";
            }

            $.growl({message: polyglot.t('profile.account_changed')
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
            Backbone.history.navigate('#smart_campaign')
            Robin.module("SmartCampaign").start();
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
