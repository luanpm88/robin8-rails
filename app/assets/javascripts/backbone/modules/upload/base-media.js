Robin.Views.BaseMediaView = Backbone.Marionette.CompositeView.extend({
  template: 'modules/upload/templates/media',
  childEvents: {
    'item:deleted': function (e) {
      var arr = [];
      this.collection.remove(e.model)
      if (this.model.get('attachments') && this.model.get('attachments').length && !this.model.get('attachments_attributes')){
        arr = _.clone(this.model.get('attachments'));
      }else{
        arr = _.clone(this.model.get('attachments_attributes'));
      }
      for(var i=0;i<arr.length;i++){
        if (e.model.get('id') && arr[i].id == e.model.get('id')){
          arr[i]._destroy = '1';
          break;
        }else if(!e.model.get('id') && arr[i].url == e.model.get('url')){
          arr.splice(i, 1);
          break;
        }
      }
      this.model.unset('attachments');
      this.model.set('attachments_attributes', arr)
    }
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
  loadExistingPhotos: function(attachment_type){
    if(this.model.get('attachments') && this.model.get('attachments').length){
      var attachments_to_load = _.map(_.filter(this.model.get('attachments'), function(attachment){
        return attachment.attachment_type == attachment_type
      }), function(item){return item})
      if (attachments_to_load.length) {
        this.collection.reset(attachments_to_load);
      }
    }
  },
  setModelParams: function(attachments_from_uploadcare, attachment_type){
    if (this.model.get('attachments') && this.model.get('attachments').length && !this.model.get('attachments_attributes')){
      var arr = _.clone(this.model.get('attachments'));
      _.each(attachments_from_uploadcare, function(value, key){
        if (!_.find(arr, function(item){return item.url == value.cdnUrl})){
          arr.push({url: value.cdnUrl, attachment_type: attachment_type, name: value.name});
        }
      }, this);
      this.model.unset('attachments');
      this.model.set('attachments_attributes', arr);
    }else {
      if(this.model.get('attachments_attributes') && this.model.get('attachments_attributes').length){
        var arr = _.clone(this.model.get('attachments_attributes'));
        _.each(attachments_from_uploadcare, function(value, key){
          if (!_.find(arr, function(item){return item.url == value.cdnUrl})){
            arr.push({url: value.cdnUrl, attachment_type: attachment_type, name: value.name});
          }
        }, this);
        this.model.unset('attachments');
        this.model.set('attachments_attributes', arr);
      }else{
        var arr = [];
          _.each(attachments_from_uploadcare, function(value, key){
            arr.push({url: value.cdnUrl, attachment_type: attachment_type, name: value.name});
          }, this);
          this.model.set("attachments_attributes", arr);
      }
    }
  }
});


