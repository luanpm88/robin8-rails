Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.TopMenuView = Marionette.LayoutView.extend({
    template: 'modules/news_room/templates/top-menu-view',
    className: 'row',
    regions: {
      logoRegion: '.logo',
      imagesRegion: '.images_region',
      videosRegion: '.videos_region',
      filesRegion: '.files_region',
      addNewsRoom: '#new_newsroom'
    },
    events: {
      'click #new_newsroom': 'openModalDialog',
      'click #save_news_room': 'saveNewsRoom',
      'click #delete_news_room': 'deleteNewsRoom',
      'click .manage': 'manageUsers',
      'click #preview_news_room': 'startPreview'
    },

    templateHelpers: function () {
      return {
        items: this.collection,
      };
    },

    initialize: function(options){
      this.collection.fetch();
      sweetAlertInitialize();
      this.modelBinder = new Backbone.ModelBinder();
      Robin.vent.on("news_room:open_edit_modal", this.openModalDialogEdit, this);
    },
    openModalDialog: function(){
      this.model.clear();
      // this.$el.find("#tagsinput").tagsinput('removeAll')
      this.render()
      this.$el.find('#newsroom_form').modal({keyboard: false });
    },
    openModalDialogEdit: function(data){
      this.model.set(data.toJSON().news_room);
      this.render()
      this.$el.find("#tagsinput").tagsinput('add', this.model.get('tags'));
      this.$el.find('#newsroom_form').modal({keyboard: false });
    },
    onRender: function(){
      var $this = this;
      Robin.user = new Robin.Models.User();
      Robin.user.fetch({
        success: function() {
          var addButtonView = new Newsroom.AddButtonView();
          $this.addNewsRoom.show(addButtonView);
        }
      });
      this.modelBinder.bind(this.model, this.el);
      this.initFormValidation();
      this.initSubdomain = this.model.attributes.subdomain_name;
      this.$el.find("#tagsinput").tagsinput();
      this.$el.find("#industries").select2({
        placeholder: 'Select...'
      });
      this.initLogoView();
      this.initMediaTab();
      if (Robin.newNewsroomFromDashboard) {
        var view = this;
        var selectIndustries = view.$el.find('#industries');
        view.collection.on('sync', function() {
          selectIndustries.find('option').remove();
          $.each(view.collection.models ,function(index,value){
            selectIndustries.append('<option value="' + value.get('id') + '">'+ value.get('name') +'</option>');
          });
          view.$el.find('#newsroom_form').modal({keyboard: false });
          Robin.newNewsroomFromDashboard = false;
        });
      }
      this.$el.find("input[type='checkbox']").iCheck({
        checkboxClass: 'icheckbox_square-blue',
        increaseArea: '20%'
      });
    },
    onShow: function(){
      if (Robin.currentUser.attributes.is_primary == false){
        this.$el.find(".manage").hide();
      }
    },
    initLogoView: function(){
      this.logoRegion.show(new Robin.Views.LogoView({
        model: this.model,
        field: 'logo_url'
      }));
    },
    initMediaTab: function(){
      this.imagesRegion.show(new Robin.Views.ImagesCollectionView({
        model: this.model,
        collection: new Robin.Collections.Attachments(),
        childView: Robin.Views.ImagesItemView
      }));
      this.videosRegion.show(new Robin.Views.VideosCollectionView({
        model: this.model,
        collection: new Robin.Collections.Attachments(),
        childView: Robin.Views.VideosItemView
      }));
      this.filesRegion.show(new Robin.Views.FilesCollectionView({
        model: this.model,
        collection: new Robin.Collections.Attachments(),
        childView: Robin.Views.FilesItemView
      }));
    },
    initFormValidation: function(){
      this.form = $('#newsroomForm').formValidation({
        framework: 'bootstrap',
        excluded: [':disabled'],
        icon: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
          company_name: {
            validators: {
              notEmpty: {
                message: 'The Company name is required'
              }
            }
          },
          email: {
            validators: {
              emailAddress: {
                message: 'The value is not a valid email address'
              }
            }
          },
          phone_number: {
            validators: {
              digits: {
                message: 'Digits only'
              }
            }
          },
          toll_free_number: {
            validators: {
              digits: {
                message: 'Digits only'
              }
            }
          },
          fax: {
            validators: {
              digits: {
                message: 'Digits only'
              }
            }
          },
          subdomain_name: {
            validators: {
              notEmpty: {
                message: 'The Subdomain name is required'
              },
              regexp: {
                regexp: /^[a-zA-Z0-9_-]*$/,
                message: 'The Subdomain name can only consist of alphanumeric characters, dashes and underscores <br>( a-z 0-9 - _ )'
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          },
          facebook_link: {
            validators: {
              uri: {
                message: 'The website address is not valid'
              }
            }
          },
          twitter_link: {
            validators: {
              uri: {
                message: 'The website address is not valid'
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          },
          instagram_link: {
            validators: {
              uri: {
                message: 'The website address is not valid'
              }
            }
          },
          linkedin_link: {
            validators: {
              uri: {
                message: 'The website address is not valid',
                allowEmptyProtocol: true
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
        if (data.fv.isValidContainer($tabPane)){
          $('a[href="#' + tabId + '"][data-toggle="tab"]')
            .removeClass('error-tab');
        }
        if (data.element.val() === '') {
          var $parent = data.element.parents('.form-group');
          $parent.removeClass('has-success');
          data.element.data('fv.icon').hide();
        }
      })
      // 
    },
    saveNewsRoom: function(e){
      if (this.form.data('formValidation') == undefined) {
        this.initFormValidation();
      };

      this.modelBinder.copyViewValuesToModel();

      var viewObj = this;
      this.form.data('formValidation').validate();
      if (this.form.data('formValidation').isValid()) {
        if (this.model.attributes.id) {
          this.model.save(this.model.attributes, {
            success: function(data){
              viewObj.$el.find('#newsroom_form').modal('hide');
              $('body').removeClass('modal-open');
              Robin.module("Newsroom").collection.add(data, {merge: true});
              Robin.module("Newsroom").collection.trigger('reset');
              Robin.user.fetch({
                success: function(data) {
                  var addButtonView = new Newsroom.AddButtonView();
                  viewObj.addNewsRoom.show(addButtonView);
                }
              });
            },
            error: function(data, response){
              viewObj.processErrors(response);
            }
          });
        }else{
          this.model.save(this.model.attributes, {
            success: function(model, data, response){
              viewObj.$el.find('#newsroom_form').modal('hide');
              $('body').removeClass('modal-open');
              if (Robin.module("Newsroom").controller.filterCriteria.page == 1) {
                if (Robin.module("Newsroom").collection.length == Robin.module("Newsroom").controller.filterCriteria.per_page) {
                  Robin.module("Newsroom").collection.pop();
                }
                Robin.module("Newsroom").collection.unshift(data);
                Robin.module("Newsroom").pagination_view.model.set({
                  page: Robin.module("Newsroom").controller.filterCriteria.page,
                  per_page:  Robin.module("Newsroom").controller.filterCriteria.per_page,
                  total_count: parseInt(response.xhr.getResponseHeader('Totalcount'),10),
                  total_pages: parseInt(response.xhr.getResponseHeader('Totalpages'),10)
                });
              };
              Robin.user.fetch({
                success: function(data) {
                  var addButtonView = new Newsroom.AddButtonView();
                  viewObj.addNewsRoom.show(addButtonView);
                }
              });
            },
            error: function(data, response){
              viewObj.processErrors(response);
            }
          });
        }
      }
    },
    processErrors: function(data){
      var errors = JSON.parse(data.responseText).errors;
      _.each(errors, function(value, key){
        this.form.data('formValidation').updateStatus(key, 'INVALID', 'serverError')
        this.form.data('formValidation').updateMessage(key, 'serverError', value.join(','))
      }, this);
    },
    startPreview: function(e){
      e.preventDefault();
      this.form.data('formValidation').validate();
      if (this.form.data('formValidation').isValid()) {
        var subdomain = this.initSubdomain + "-preview"
        var parentId = this.model.attributes.id;
        tempModel = new Robin.Models.NewsRoom(this.model.attributes);
        previewData = tempModel.attributes;
        previewData.id = '';
        previewData.subdomain_name = subdomain;
        previewData.parent_id = parentId;
        $.post("/preview_news_rooms.json", { _method:'POST', utf8: "&#x2713;", preview_news_room:previewData})
            .done(function(userSession, response) {
            })
            .fail(function(response) {
              console.log("error: " + response);
        });
        var windowUrl = location.host.split('.');
        var windowLocation = windowUrl.length == 3 ? _.last(windowUrl, 2).join('.') : location.host;
        if (windowLocation == "localhost:3000") { windowLocation = "lvh.me:3000"} //for development only
        var url = "http://" + subdomain +"." + windowLocation
        window.open(url);
      }
    },
    deleteNewsRoom: function(){
      var viewObj = this;
      if (this.model.get('default_news_room')){
        swal({
          title: "This is default newsroom",
          text: "You are not able to delete it!",
          type: "error",
          showCancelButton: false,
          confirmButtonClass: 'btn',
          confirmButtonText: 'ok'
        });
      }else{
        swal({
          title: "Delete this newsroom?",
          text: "You will not be able to recover it!",
          type: "error",
          showCancelButton: true,
          confirmButtonClass: 'btn-danger',
          confirmButtonText: 'Delete'
        },
        function(isConfirm) {
          if (isConfirm) {
            viewObj.model.destroy({
              success: function(model, response){
                viewObj.$el.find('#newsroom_form').modal('hide');
                var page = Robin.module("Newsroom").controller.filterCriteria.page
                if(Robin.module("Newsroom").collection.length == 1 && page > 1 || page == 1) {
                  Robin.module("Newsroom").controller.paginate(1);
                }else {
                  Robin.module("Newsroom").controller.paginate(page);
                };
                Robin.user.fetch({
                  success: function(data) {
                    var addButtonView = new Newsroom.AddButtonView();
                    viewObj.addNewsRoom.show(addButtonView);
                  }
                });
              },
              error: function(data){
                console.warn('error', data);
              }
            });
          }
        });
      }
      
    },
    onDestroy: function(){
      Robin.vent.off("news_room:open_edit_modal", this.openModalDialogEdit);
      this.modelBinder.unbind();
    },
    manageUsers: function() {
      if (Robin.ManageUsers._isInitialized){
        Robin.ManageUsers.Show.Controller.showManageUsersPage();
      } else {
        Robin.module('ManageUsers').start();
      }
    }

  });
});
