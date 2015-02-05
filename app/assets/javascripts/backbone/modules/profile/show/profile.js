Robin.module('Profile.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.ProfilePage = Backbone.Marionette.LayoutView.extend({
    template: JST['pages/profile'],

    events: {
      'submit form' : 'updateProfile',
      'reset form'  :'showSocial',  //Should be replaced with Dashboard when ready,
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
      e.preventDefault();
      el = $(this.el);
  
      this.modelBinder.copyViewValuesToModel();
      this.model.save(this.model.attributes, {
        success: function(userSession, response) {
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
              $.growl(formatted_field + ' ' + error, {
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
    showSocial: function() {
      Robin.layouts.main.getRegion('content').show(new Robin.Views.Layouts.Social());
    },
  });
});