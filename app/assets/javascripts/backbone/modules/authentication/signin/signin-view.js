Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.SignInView = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/signin',

    events: {
      'click #login' : 'login',
      'click .btn-facebook' : 'socialSignIn',
      'click .btn-google-plus' : 'socialSignIn',
      'click .btn-weibo' : 'socialSignIn',
    },

    initialize: function() {
      this.model = new Robin.Models.UserSession();
      this.modelBinder = new Backbone.ModelBinder();
    },

    onRender: function() {
      this.modelBinder.bind(this.model, this.el);
      $('.signup-tag').text(polyglot.t('login.title'));
      $('.nav.fixed a').removeClass('active');
      $('#login-link').addClass('active');
    },

    login: function(e) {
      e.preventDefault();

      el = $(this.el);

      this.modelBinder.copyViewValuesToModel();

      this.model.save(this.model.attributes, {
        success: function(data, response, jqXHR){
          var token = jqXHR.xhr.getResponseHeader('X-CSRF-Token');
          if (token) {
            $("meta[name='csrf-token']").attr('content', token);
            Robin.finishSignIn(response);
          }
        },
        error: function(userSession, response) {
          var result = $.parseJSON(response.responseText);
          this.$('#alert-danger').show();
          this.$('#alert-danger').text(result.error);
        }
      });
    },

    socialSignIn: function(e) {
      e.preventDefault();
      var currentView = this;

      if ($(e.target).children().length != 0) {
        var provider = $(e.target).attr('id');
      } else {
        var provider = $(e.target).parent().attr('id');
      };

      var url = '/users/auth/' + provider,
      params = 'location=0,status=0,width=800,height=600';
      currentView.connect_window = window.open(url, "connect_window", params);

      currentView.interval = window.setInterval((function() {
        if (currentView.connect_window.closed) {
          $.get( "/users/get_current_user", function( data ) {
            window.clearInterval(currentView.interval);
            if (data != undefined) {
              Robin.finishSignIn(data);
            }
          });
        }
      }), 500);
    }

  });
});
