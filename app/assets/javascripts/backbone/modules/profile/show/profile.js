Robin.module('Profile.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.ProfilePage = Backbone.Marionette.LayoutView.extend({
    template: 'modules/profile/show/templates/profile',

    events: {
      'submit form' : 'updateProfile',
      'reset form'  :'cancel',  //Should be replaced with Dashboard when ready,
    },
  
    initialize: function() {
      this.model = new Robin.Models.UserProfile(Robin.currentUser.attributes)
      this.modelBinder = new Backbone.ModelBinder();
    },
  
    onRender: function() {
      this.modelBinder.bind(this.model, this.el);
  
      //Avatar uploader
      setTimeout(function(){
        uploadcare.Widget('[role=uploadcare-uploader]').onUploadComplete(function(info){
          document.getElementById("avatar-image").src = info.cdnUrl;
          // custom Amazon S3 image storage is needed in order to actually store the image
        });
      }, 0);
    },
  
    updateProfile: function(e) {
      var r = this.model.attributes

      e.preventDefault();
      el = $(this.el);

      this.modelBinder.copyViewValuesToModel();
      this.model.save(this.model.attributes, {
        success: function(userSession, response) {
          Robin.currentUser.attributes = r;
          Robin.currentUser.attributes.current_password = "";
          $.growl({message: 'Your account data has been successfully changed'
          },{
            element: '#growler-alert',
            type: 'success',
            offset: 147,
            placement: {
              from: "top",
              align: "right"
            },
          });
        },
        error: function(userSession, response) {
          var result = $.parseJSON(response.responseText);
          _(result.errors).each(function(errors,field) {
            $('input[name=' + field + ']').addClass('error');
            _(errors).each(function(error, i) {
              formatted_field = s(field).capitalize().value().replace('_', ' ');
              growl_message = (formatted_field + ' ' +error);
              if (growl_message === "Current password can't be blank"){
                growl_message = "You need to enter current password in order to set a new one"
              }
              if (growl_message === "Password confirmation doesn't match Password"){
                growl_message = "New Password and Confirmation don't match"
              }
              $.growl(growl_message, {
                element: '#growler-alert',
                type: "danger",
                offset: 147,
                placement: {
                  from: "top",
                  align: "right"
                },
              });
            });
          });
        }
      });
    },
  
    //Should be replaced with Dashboard when ready
    cancel: function() {
      Robin.stopOtherModules();
      Robin.module('Dashboard').start();
    },
  });
});