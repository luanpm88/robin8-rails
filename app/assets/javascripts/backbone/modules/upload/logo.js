Robin.Views.LogoView = Backbone.Marionette.ItemView.extend({
  template: 'modules/upload/templates/logo',
  initialize: function(options){
    this.options = options;
  },
  onShow: function() {
    var viewObj = this;
    this.widget = uploadcare.Widget('[role=uploadcare-uploader]').onUploadComplete(function(info){
        $("#logo-image").attr('src', info.cdnUrl);
        viewObj.model.set(viewObj.options.field,  info.cdnUrl);
      });
    if (this.model.get(this.options.field)){
      $("#logo-image").attr('src', this.model.get(this.options.field));
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