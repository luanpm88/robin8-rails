Robin.Views.Layouts.Unauthenticated = Backbone.Marionette.LayoutView.extend({
  template: 'layouts/templates/unauthenticated',

  events: {
    'click .toggle-topbar': 'toggleTapbar'
  },

  regions: {
    signUpForm: ".form-step",
  },

  initialize: function() {
    $(document).foundation();
  },

  toggleTapbar: function() {
    var topBarSection = $('.top-bar-section')
    var isTopBarSectionVisible = $('.top-bar-section').is(':visible');
    var topBarSectionHeight = $('.top-bar-section').height();
    if(isTopBarSectionVisible) {
      topBarSection.animate({
        height: '0px'
      }, function() {
        topBarSection.css({
          display: 'none',
          height: topBarSectionHeight
        });
      });
    } else {
      topBarSection.css({
        display: 'block',
        height: '0px'
      });
      topBarSection.animate({
        height: topBarSectionHeight
      });
    }
  },

  templateHelpers: function () {
    return {
      hostName: window.location.hostname
    }
  }

});
