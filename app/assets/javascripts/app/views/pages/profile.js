Robin.Views.Profile = Backbone.Marionette.ItemView.extend({
  template: JST['pages/profile'],

  events: {
    'submit form' : 'updateProfile',
    'reset form': 'showSocial',  //Should be replaced with Dashboard when ready
  },

  initialize: function() {
    this.model = new Robin.Models.UserProfile(Robin.currentUser.attributes)
    this.modelBinder = new Backbone.ModelBinder();
  },

  onRender: function() {
    this.modelBinder.bind(this.model, this.el);
  },

  updateProfile: function(e) {
    e.preventDefault();
    el = $(this.el);

    this.modelBinder.copyViewValuesToModel();
    this.model.save(this.model.attributes, {
      success: function(userSession, response) {
        document.getElementById('alert-box').innerHTML="goood";
        $.growl({message: 'Your account data has been successfully changed'
        },{
          type: 'success',
          offset: 100,
        });
      },
      error: function(userSession, response) {
        var result = $.parseJSON(response.responseText);
        _(result.errors).each(function(errors,field) {
          $('input[name=' + field + ']').addClass('error');
          _(errors).each(function(error, i) {
            formatted_field = s(field).capitalize().value().replace('_', ' ');
            $.growl(formatted_field + ' ' + error, {
              type: "danger",
              offset: 100,
            });
          });
        });
      }
    });
  },

  //Should be replaced with Dashboard when ready
  showSocial: function() {
    Robin.layouts.main.getRegion('content').show(new Robin.Views.Social());
  },
});