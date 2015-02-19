Robin.Views.MediaView = Backbone.Marionette.ItemView.extend({
  template: 'modules/upload/templates/media',
  initialize: function(options){
    if (this.model.get('attachments_attributes')){
      this.model.unset('attachments_attributes');
    }
    this.options = options;
  },
  onShow: function() {
    var viewObj = this;
    setTimeout(function(){
      viewObj.photoWidget = uploadcare.MultipleWidget('[role=uploadcare-uploader][data-multiple][data-photo]').onChange(function(fileGroup){
        $(".photos_list").empty();
        if (fileGroup) {
          $.when.apply(null, fileGroup.files()).done(function() {
            viewObj.setModelParams(arguments, 'image');
            $.each(arguments, function(i, fileInfo) {
              var src = fileInfo.cdnUrl + '-/scale_crop/160x160/center/';
              $(".photos_list").append("<li><div><img src="+src+"><a href='#' class='delete'><i class='fa fa-close'></i></a></div></li>");
            });
          });
        }
      });
      viewObj.loadExistingPhotos('image', viewObj.photoWidget);




      viewObj.videoWidget = uploadcare.MultipleWidget('[role=uploadcare-uploader][data-multiple][data-video]').onChange(function(fileGroup){
        $(".videos_list").empty();
        if (fileGroup) {
          $.when.apply(null, fileGroup.files()).done(function() {
            viewObj.setModelParams(arguments, 'video');
            $.each(arguments, function(i, fileInfo) {
              $(".videos_list").append("<li><div><a href="+fileInfo.cdnUrl+" class='delete'>"+fileInfo.name+"</a></div></li>");
            });
          });
        }
      });
      viewObj.loadExistingPhotos('video', viewObj.videoWidget);


      viewObj.fileWidget = uploadcare.MultipleWidget('[role=uploadcare-uploader][data-multiple][data-file]').onChange(function(fileGroup){
        $(".files_list").empty();
        if (fileGroup) {
          $.when.apply(null, fileGroup.files()).done(function() {
            viewObj.setModelParams(arguments, 'file');
            $.each(arguments, function(i, fileInfo) {
              var src = fileInfo.cdnUrl + '-/scale_crop/160x160/center/';
              $(".files_list").append("<li><div><a href="+fileInfo.cdnUrl+" class='delete'>"+fileInfo.name+"</a></div></li>");
            });
          });
        }
      });
      viewObj.loadExistingPhotos('file', viewObj.fileWidget);

      viewObj.pushValidations();
    }, 0);
  },
  fileTypeLimit: function(types) {
    types = types.split(' ');
    return function(fileInfo) {
      if (fileInfo.name === null) {
        return;
      }
      var extension = fileInfo.name.split('.').pop();
      if (types.indexOf(extension) == -1) {
        throw new Error("fileType");
      }
    };
  },
  pushValidations: function(widgets){
    var viewObj = this;
    $('[role=uploadcare-uploader][data-file-types]').each(function() {
      var input = $(this);
      var widget;
      if (input.data('multiple')) {
        widget = uploadcare.MultipleWidget(input);
      } else {
        widget = uploadcare.Widget(input);
      }
      widget.validators.push(viewObj.fileTypeLimit(input.data('file-types')));
    });
  },
  loadExistingPhotos: function(attachment_type, widget){
    if(this.model.get('attachments') && this.model.get('attachments').length){
      var attachments_to_load = _.map(_.filter(this.model.get('attachments'), function(attachment){
        return attachment.attachment_type == attachment_type
      }), function(item){return item.url})
      if (attachments_to_load.length)
        widget.value(attachments_to_load);
    }
  },
  setModelParams: function(attachments_from_uploadcare, attachment_type){
    if (this.model.get('attachments') && this.model.get('attachments').length && !this.model.get('attachments_attributes')){
      var arr = _.clone(this.model.get('attachments'));
      _.each(attachments_from_uploadcare, function(value, key){
        if (!_.find(arr, function(item){return item.url == value.cdnUrl})){
          arr.push({url: value.cdnUrl, attachment_type: attachment_type});
        }
      }, this);
      _.each(arr, function(value, key){
        if (value.attachment_type == attachment_type && !_.find(attachments_from_uploadcare, function(item){return item.cdnUrl == value.url})){
          value._destroy = '1';
        }
      }, this);
      this.model.unset('attachments');
      this.model.set('attachments_attributes', arr);
    }else {
      if(this.model.get('attachments_attributes') && this.model.get('attachments_attributes').length){
        var arr = _.clone(this.model.get('attachments_attributes'));
        
        _.each(attachments_from_uploadcare, function(value, key){
          if (!_.find(arr, function(item){return item.url == value.cdnUrl})){
            arr.push({url: value.cdnUrl, attachment_type: attachment_type});
          }
        }, this);
        _.each(arr, function(value, key){
          if (value.attachment_type == attachment_type && !_.find(attachments_from_uploadcare, function(item){return item.cdnUrl == value.url})){
            if (value.id) {
              value._destroy = '1';
            }else{
              arr.splice(key, 1);  
            }
          }
        }, this);
        this.model.unset('attachments');
        this.model.set('attachments_attributes', arr);
      }else{
        var arr = [];
          _.each(attachments_from_uploadcare, function(value, key){
            arr.push({url: value.cdnUrl, attachment_type: attachment_type});
          }, this);
          this.model.set("attachments_attributes", arr);
      }
    }
  }
});


