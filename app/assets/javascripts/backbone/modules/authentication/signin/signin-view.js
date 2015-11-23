Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.SignInView = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/signin',

    events: {
      'click #login' : 'login',
      'click .btn-facebook' : 'socialSignIn',
      'click .btn-google-plus' : 'socialSignIn',
      'click .btn-weibo' : 'socialSignIn',
      'click #wechat' : 'socialSignIn',
      'click #wechat_third' : 'socialSignIn',
    },
    ui: {
      world: 'world',
      china: 'china'
    },
    initialize: function() {
      this.model = new Robin.Models.UserSession();
      this.kolModel = new Robin.Models.KOLSession();
      this.modelBinder = new Backbone.ModelBinder();
      this.kolBinder = new Backbone.ModelBinder();
    },

    onRender: function() {
      var $this = this;
      this.modelBinder.bind(this.model, this.el);
      this.kolBinder.bind(this.kolModel, this.el);
      $('.signup-tag').text(polyglot.t('login.title'));
      $('.nav.fixed a').removeClass('active');
      $('#login-link').addClass('active');
      _.defer(function(){
        $this.$('#email').focus();
      });
    },

    login: function(e) {
      e.preventDefault();

      el = $(this.el);
      var that = this;

      this.modelBinder.copyViewValuesToModel();
      this.kolBinder.copyViewValuesToModel();
      var loggedIn = function(data, response, jqXHR){
        var token = jqXHR.xhr.getResponseHeader('X-CSRF-Token');
        if (token) {
          $("meta[name='csrf-token']").attr('content', token);
          Robin.finishSignIn(response);
        }
      }
      this.model.save(this.model.attributes, {
        success: loggedIn,
        error: function(userSession, response) {
          that.kolModel.save(that.kolModel.attributes, {
            success: loggedIn,
            error: function(data, response) {
              var result = $.parseJSON(response.responseText);
              this.$('#alert-danger').show();
              this.$('#alert-danger').text(result.error);
            }
          });
        }
      });
    },

    socialSignIn: function(e) {
      e.preventDefault();
      var currentView = this;

      var fiveMins = new Date();
      fiveMins.setMinutes(fiveMins.getMinutes() + 5);
      $.cookie("kol_social", "yeah", {expires: fiveMins, path: "/"});
      $.cookie("kol_weibo_signin", "yeah", {expires: fiveMins, path: "/"});

      if ($(e.target).children().length != 0) {
        var provider = $(e.target).attr('id');
      } else {
        var provider = $(e.target).parent().attr('id');
      };

      var url = '/users/auth/' + provider;

      params = 'location=0,status=0,width=800,height=600';
      currentView.connect_window = window.open(url, "connect_window", params);
      currentView.interval = window.setInterval((function() {
        if (currentView.connect_window.closed) {
          if ($.cookie('kol_signin') == 'no') {
            current_entity_path = "/users/get_current_user";
          } else {
            current_entity_path = "/kols/get_current_kol";
          }
          $.get( current_entity_path, function( data ) {
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
