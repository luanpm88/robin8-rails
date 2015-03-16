Robin.Views.VideosCollectionView = Robin.Views.BaseMediaView.extend({
  template: 'modules/upload/templates/_videos-view',
  childViewContainer: "#videos",
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
        $(".modal-backdrop").height($('.modal').prop("scrollHeight"));
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
      viewObj.$el.find(".image-preview-multiple-plus .uploadcare-widget-button-open").text("");
      viewObj.$el.find(".image-preview-multiple-plus .uploadcare-widget-button-open").addClass("fa fa-plus-square");
      viewObj.pushValidations();
    }, 0);
  },
})