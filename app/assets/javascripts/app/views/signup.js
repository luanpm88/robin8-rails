Robin.Views.signUpView = Backbone.Marionette.ItemView.extend( {
  template: JST['users/signup'],

  events: {
    'submit form' : 'signup'
  },

  initialize: function() {
    this.model = new Robin.Models.UserRegistration();
    this.modelBinder = new Backbone.ModelBinder();
  },

  onRender: function() {
    this.modelBinder.bind(this.model, this.el);
  },

  signup: function(e) {
    e.preventDefault();
    
    el = $(this.el);
    // el.find('input.btn-primary').button('loading');
    el.find('.alert-error').remove();
    el.find('.help-block').remove();
    el.find('.control-group.error').removeClass('error');

    this.model.save(this.model.attributes, {
      success: function(userSession, response) {
         Robin.currentUser = new Robin.Models.User(response);
      },
      error: function(userSession, response) {
        var result = $.parseJSON(response.responseText);
        _(result.errors).each(function(errors,field) {
          $('#'+field+'_group').addClass('error');
          _(errors).each(function(error, i) {
            $('#'+field+'_group .controls').append(error);
          });
        });
      }
    });
  },

});