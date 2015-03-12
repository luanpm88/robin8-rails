Robin.Views.Layouts.Main = Backbone.Marionette.LayoutView.extend({
  template: 'layouts/templates/main',

  regions: {
    sidebar: "#sidebar-wrapper",
    saySomething: '#say-something',
    content: '#page-content'
  },

  events: {
    'click #sign-out': 'signOut'
  },

  onShow: function(options) {
    var nameHolder = this.$el.find('#userDropdown span.text');
    var fName = Robin.currentUser.attributes.first_name;
    var lName = Robin.currentUser.attributes.last_name;
    var name = Robin.currentUser.attributes.name;
    var email = Robin.currentUser.attributes.email;
    if (fName!= null && fName!=0 && lName!= null && lName!=0){
      nameHolder.text(fName + ' ' + lName);
    } else if (email.length > 0) {
      nameHolder.text(email);
    }
  },

  signOut: function(e) {
    e.preventDefault();
    Robin.stopOtherModules();
    Robin.currentUser.signOut().done(function(data){
      Robin.vent.trigger("authentication:logged_out");
      $.growl('Signed out successfully.',{
        type: 'success'
      });
    });
  }

});