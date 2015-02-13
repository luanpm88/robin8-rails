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
      this.$el.find("#tagsinput").tagsinput();
    },
    saveNewsRoom: function(e){
      var viewObj = this;
      if (this.model.attributes.id) {
        this.model.save(this.model.attributes, {
          success: function(data){
            viewObj.$el.find('#newsroom_form').modal('hide');
            Robin.module("Newsroom").collection.add(data, {merge: true});
            Robin.module("Newsroom").collection.trigger('reset');
          },
          error: function(data){
            console.warn('error', data);
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
          error: function(data){
            console.warn('error', data);
          }
        });
      }
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
