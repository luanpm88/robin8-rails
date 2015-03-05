Robin.Views.ImagesCollectionView = Robin.Views.BaseMediaView.extend({
  template: 'modules/upload/templates/_images-view',
  childViewContainer: "ul",
  initialize: function(options){
    if (this.model.get('attachments_attributes')){
      this.model.unset('attachments_attributes');
    }
    this.options = options;
    this.loadExistingPhotos('image');
  },
  onShow: function() {
    var viewObj = this;
    setTimeout(function(){
      viewObj.photoWidget = uploadcare.MultipleWidget('[role=uploadcare-uploader][data-multiple][data-photo]').onChange(function(fileGroup){
        if (fileGroup) {
          $.when.apply(null, fileGroup.files()).done(function() {
            viewObj.setModelParams(arguments, 'image');
            $.each(arguments, function(i, fileInfo) {
              var src = fileInfo.cdnUrl + '-/scale_crop/160x160/center/';
              viewObj.collection.add(new Robin.Models.Attachment({thumbnail: src }));
            });
            viewObj.photoWidget.value(null);
          });
        }
      });
      viewObj.pushValidations();
    }, 0);
  },
})