Robin.Views.Layouts.Main = Backbone.Marionette.LayoutView.extend({
  getTemplate: Robin.template('layouts/templates/main'),

  regions: {
    sidebar: "#sidebar-wrapper",
    saySomething: '#say-something',
    content: '#page-content'
  },

  events: {
    'click #sign-out': 'signOut'
  },

  onShow: function(options) {
    var user = Robin.KOL ? Robin.currentKOL : Robin.currentUser;
    var nameHolder = this.$el.find('#userDropdown span.text');
    var fName = user.attributes.first_name;
    var lName = user.attributes.last_name;
    var name = user.attributes.name;
    var email = user.attributes.email;
    if (fName!= null && fName!=0 && lName!= null && lName!=0){
      nameHolder.text(fName + ' ' + lName);
    } else if (email.length > 0) {
      nameHolder.text(email);
    }
    Robin.vent.on("nameChanged", function(newName){
      nameHolder.text(newName);
    });
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
