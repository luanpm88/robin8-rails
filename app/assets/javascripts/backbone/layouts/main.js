Robin.Views.Layouts.Main = Backbone.Marionette.LayoutView.extend({
  template: 'layouts/templates/main',

  regions: {
    sidebar: "#sidebar-wrapper",
    saySomething: '#say-something',
    content: '#page-content'
  },

  events: {
    'click nav, div#main-wrapper': 'hideSaySomething',
    'click #nav-profile': 'showProfile',
  },

  onShow: function(options) {
    var nameHolder = this.$el.find('#userDropdown');
    var fName = Robin.currentUser.attributes.first_name;
    var lName = Robin.currentUser.attributes.last_name;
    var email = Robin.currentUser.attributes.email;
    console.log (nameHolder);
    console.log (Robin.currentUser.attributes.email);
    if (fName.length > 0 && lName.length > 0) {
      nameHolder.text(fName + ' ' + lName);
    } else if (email.length > 0) {
      nameHolder.text(email);
    }
  },

  hideSaySomething: function(e) {
    console.log('clicked');
    // Robin.vent.trigger("saySomething:hide");
  },

  showProfile: function() {
    Robin.stopOtherModules();
    Robin.module('Profile').start();
  },
});