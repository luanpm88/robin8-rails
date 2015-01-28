Robin.Views.signInView = Backbone.Marionette.ItemView.extend( {
  template: 'templates/users/signin',

  events: {
    'submit' : 'submit'
  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  },

  initialize: function() {
    console.log('init view')
  }
});