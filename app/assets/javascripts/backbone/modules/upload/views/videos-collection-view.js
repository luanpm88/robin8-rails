Robin.Views.VideosCollectionView = Robin.Views.BaseMediaView.extend({
  template: 'modules/upload/templates/_videos-view',
  childViewContainer: "ul",
  initialize: function(options){
    if (this.model.get('attachments_attributes')){
      this.model.unset('attachments_attributes');
    }
    this.options = options;
    this.loadExistingPhotos('video');
  },
  onShow: function() {
    var viewObj = this;
    setTimeout(function(){
      viewObj.videoWidget = uploadcare.MultipleWidget('[role=uploadcare-uploader][data-multiple][data-video]').onChange(function(fileGroup){
        if (fileGroup) {
          $.when.apply(null, fileGroup.files()).done(function() {
            viewObj.setModelParams(arguments, 'video');
            $.each(arguments, function(i, fileInfo) {
              viewObj.collection.add(new Robin.Models.Attachment({
                url: fileInfo.cdnUrl,
                name: fileInfo.name
              }));
            });
            viewObj.videoWidget.value(null);
          });
        }
      });
      viewObj.pushValidations();
    }, 0);
  },
})