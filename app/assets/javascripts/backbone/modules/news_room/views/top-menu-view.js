Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.TopMenuView = Marionette.ItemView.extend({
    template: 'modules/news_room/templates/top-menu-view',
    className: 'row',
    events: {
      'click #new_newsroom': 'openModalDialog',
      'click #save_news_room': 'saveNewsRoom',
      'click #delete_news_room': 'deleteNewsRoom'
    },
    initialize: function(options){
      var viewObj = this;
      this.modelBinder = new Backbone.ModelBinder();
      Robin.vent.on("news_room:open_edit_modal", function(data) {
        viewObj.openModalDialogEdit(data);
      });
      this.collection.fetch();
    },
    templateHelpers: function () {
      return {
        items: this.collection
      };
    },
    openModalDialog: function(){
      this.model.clear();
      // this.$el.find("#tagsinput").tagsinput('removeAll')
      this.render()
      this.$el.find('#newsroom_form').modal({ backdrop: 'static', keyboard: false });
    },
    openModalDialogEdit: function(data){
      this.model.set(data.toJSON().news_room);
      this.render()
      this.$el.find("#tagsinput").tagsinput('add', this.model.get('tags'));
      this.$el.find('#newsroom_form').modal({ backdrop: 'static', keyboard: false });
    },
    onRender: function(){
      this.modelBinder.bind(this.model, this.el);
      this.initFormValidation();
      this.$el.find("#tagsinput").tagsinput();
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
          subdomain_name: {
            validators: {
              notEmpty: {
                message: 'The Subdomain name is required'
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          }
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
    saveNewsRoom: function(e){
      var viewObj = this;
      this.form.data('formValidation').validate();
      if (this.form.data('formValidation').isValid()) {
        if (this.model.attributes.id) {
          this.model.save(this.model.attributes, {
            success: function(data){
              viewObj.$el.find('#newsroom_form').modal('hide');
              Robin.module("Newsroom").collection.add(data, {merge: true});
              Robin.module("Newsroom").collection.trigger('reset');
            },
            error: function(data, response){
              viewObj.processErrors(response);
            }
          });
        }else{
          this.model.save(this.model.attributes, {
            success: function(data){
              viewObj.$el.find('#newsroom_form').modal('hide');
              if (Robin.module("Newsroom").controller.filterCriteria.page == 1) {
                Robin.module("Newsroom").collection.unshift(data);
                Robin.module("Newsroom").collection.pop();
              }
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
    deleteNewsRoom: function(){
      var viewObj = this;
      this.model.destroy({
        success: function(model, response){
          viewObj.$el.find('#newsroom_form').modal('hide');
          var page = Robin.module("Newsroom").controller.filterCriteria.page
          if(Robin.module("Newsroom").collection.length == 1 && page > 1 || page == 1) {
            Robin.module("Newsroom").controller.paginate(1);
          }else {
            Robin.module("Newsroom").controller.paginate(page);
          }
        },
        error: function(data){
          console.warn('error', data);
        }
      });
    },
    onDestroy: function(){
      this.modelBinder.unbind();
    }
  });
});
