Robin.Views.LogoView = Backbone.Marionette.ItemView.extend({
  template: 'modules/upload/templates/logo',
  initialize: function(options){
    this.options = options;
  },
  onShow: function() {
    var viewObj = this;
    this.widget = uploadcare.Widget('[role=uploadcare-uploader]').onUploadComplete(function(info){
      //create release thumbnail
      if (viewObj.model.urlRoot == '/releases') {
        var thumbSrc = info.cdnUrl + '-/preview/340x340/-/stretch/off/-/resize/340x340/';
        $("#logo-image").attr('src', thumbSrc);
        viewObj.model.set('thumbnail', thumbSrc);
      } else {
        $("#logo-image").attr('src', info.cdnUrl);
      }
      //set model logo
      if (viewObj.model.urlRoot == '/news_rooms') {
         var imgSrc = info.cdnUrl + '-/preview/340x340/';
         viewObj.model.set(viewObj.options.field, imgSrc);
       } else {
         viewObj.model.set(viewObj.options.field, info.cdnUrl);
       }
       //nailthumb
       $('#image-uploader-logo').nailthumb({width:200,height:200,method:'resize',fitDirection:'center'});
    });

    if (this.model.get(this.options.field)){
      if (viewObj.model.urlRoot == '/releases') {
        var logoSrc = this.model.get('thumbnail');
      } else {
        var logoSrc = this.model.get(this.options.field);
      }
      $('#logo-image').attr('src', logoSrc);
      $('#image-uploader-logo').nailthumb({width:200,height:200,method:'resize',fitDirection:'center'});
    }

    this.widget.validators.push(this.maxFileSize(3145728));
  },
  
  maxFileSize: function(size) {
    return function(fileInfo) {
      if (fileInfo.size !== null && fileInfo.size > size) {
        throw new Error("fileMaximumSize");
      };
    };
  }

});