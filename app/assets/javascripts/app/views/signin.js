window.gplusCallback = function( authResult ) {
  token = authResult.id_token
  if (authResult['status']['signed_in']) {
      if (authResult['status']['method'] == 'PROMPT') {
        gapi.client.load('oauth2', 'v2', function () {
          gapi.client.oauth2.userinfo.get().execute(function (resp) {
            authResponse = {
              token: resp.token,
              uid: resp.id,
              email: resp.email,
              name: resp.name,
              provider: 'google_oauth2'
            }
            $.ajax({
                type: 'POST',
                url: '/users/login_by_gplus',
                dataType: 'json',
                data: {info: authResponse},
                success: function(data, textStatus, jqXHR) {
                  Robin.currentUser = new Robin.Models.User(data);
                },
                error: function(jqXHR, textStatus, errorThrown) {
                  console.log(textStatus);
                }
              });

          })
        });
      }
  } else {
    alert('Sign-in state: ' + authResult['error']);
  }
}

Robin.Views.signInView = Backbone.Marionette.ItemView.extend( {
  template: JST['users/signin'],

  events: {
    'submit form' : 'login',
    'click .btn-facebook' : 'loginFB',
    'click .btn-google-plus' : 'loginGoogle',
  },

  initialize: function() {
    this.model = new Robin.Models.UserSession();
    this.modelBinder = new Backbone.ModelBinder();
  },

  onRender: function() {
    this.modelBinder.bind(this.model, this.el);
  },

  login: function(e) {
    e.preventDefault();

    el = $(this.el);
    
    this.model.save(this.model.attributes, {
      success: function(userSession, response) {
        Robin.currentUser = new Robin.Models.User(response);
        Robin.vent.trigger("authentication:logged_in");
      },
      error: function(userSession, response) {
        var result = $.parseJSON(response.responseText);
        $.growl(result.error, {
          type: "danger",
        });
      }
    });
  },

  loginFB: function(e) {
    e.preventDefault();
    FB.login(function(response) {
      if(response.authResponse) {
        console.log(response.authResponse)
        // $.ajax({
        //   type: 'POST',
        //   url: '/users/auth/facebook/callback',
        //   dataType: 'json',
        //   data: {signed_request: response.authResponse.signedRequest},
        //   success: function(data, textStatus, jqXHR) {
        //     // Handle success case
        //   },
        //   error: function(jqXHR, textStatus, errorThrown {
        //     // Handle error case
        //   })});
      }});
  },

  signin: function(e) {
    console.log('fff');
  },

  loginGoogle: function(e) {
    e.preventDefault();
    
    gapi.auth.signIn({
        'clientid': '639174820348-qqkeokqa6lh7sirppbme6mpvg1s95na4.apps.googleusercontent.com',
        'cookiepolicy': 'single_host_origin',
        'scope': 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email',
        'callback': 'gplusCallback',
        'approvalprompt': 'force'
    });
  },
 


});