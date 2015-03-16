Robin.Views.FilesCollectionView = Robin.Views.BaseMediaView.extend({
  template: 'modules/upload/templates/_files-view',
  childViewContainer: "#files",
  initialize: function(options){
    if (this.model.get('attachments_attributes')){
      this.model.unset('attachments_attributes');
    }
    this.options = options;
    this.loadExistingPhotos('file');
  },
  onShow: function() {
    var viewObj = this;
    setTimeout(function(){
      viewObj.fileWidget = uploadcare.MultipleWidget('[role=uploadcare-uploader][data-multiple][data-file]').onChange(function(fileGroup){
        $(".modal-backdrop").height($('.modal').prop("scrollHeight"));
        if (fileGroup) {
          $.when.apply(null, fileGroup.files()).done(function() {
            viewObj.setModelParams(arguments, 'file');
            $.each(arguments, function(i, fileInfo) {
              viewObj.collection.add(new Robin.Models.Attachment({
                url: fileInfo.cdnUrl,
                name: fileInfo.name
              }));
            });
            viewObj.fileWidget.value(null);
          });
        }
      });
      viewObj.pushValidations();
      viewObj.$el.find(".image-preview-multiple-plus .uploadcare-widget-button-open").text("");
      viewObj.$el.find(".image-preview-multiple-plus .uploadcare-widget-button-open").addClass("fa fa-plus-square");
    }, 0);
  },
})