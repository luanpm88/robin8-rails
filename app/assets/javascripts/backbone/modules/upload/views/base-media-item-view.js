Robin.Views.BaseMediaItemView = Backbone.Marionette.ItemView.extend({
  template: false,
  events: {
    'click .delete-item': 'deleteItem'
  },
  deleteItem: function(e){
    console.log('The button was clicked.');
    this.triggerMethod('item:deleted');
  }
});