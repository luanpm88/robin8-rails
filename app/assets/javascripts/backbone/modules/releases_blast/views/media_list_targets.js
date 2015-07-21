Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.MediaListLayout = Marionette.LayoutView.extend({
    template: 'modules/releases_blast/templates/media-list/layout',
    regions: {
      uploadMediaListRegion: "#upload-media-list",
      selectedMediaListsRegion: "#selected-media-lists"
    }
  });
  
  ReleasesBlast.UploadMediaListView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/media-list/upload-media-list',
    className: 'well',
    collection: Robin.Collections.MediaLists,
    ui: {
      tooltipFormatInfo: "[data-toggle=tooltip]",
      fileInput: "[name=media_list_file]",
      form: "form",
      mediaListSelect: "select"
    },
    attributes: {
      "style": "box-shadow: none; border: 1px solid #ccc;"
    },
    events: {
      "change @ui.fileInput": "fileInputChanged",
      "click button": "fileUploadButtonClicked",
      "change @ui.mediaListSelect": "mediaSelectChanged"
    },
    collectionEvents: {
      "reset add remove": "render",
    },
    initialize: function(options){
      this.pitchContactsCollection = options.pitchContactsCollection;
      this.selectedMediaListsCollection = options.selectedMediaListsCollection;
    },
    onRender: function(){
      var curView = this;
      curView.initTooltip();
      if (Robin.user.get('can_create_media_list') != true) {
        curView.$el.find("#upload_button").addClass('disabled-unavailable');
      } else {
        curView.$el.find("#upload_button").removeClass('disabled-unavailable');
      }
    },
    initTooltip: function(){
      this.ui.tooltipFormatInfo.tooltip();
    },
    mediaSelectChanged: function(e){
      var id = parseInt($(e.currentTarget).val());
      if (id !== -1){
        var model = this.collection.findWhere({id: id});
        this.selectedMediaListsCollection.add(model, {
          pitchContactsCollection: this.pitchContactsCollection
        });
      }
    },
    fileInputChanged: function(e){
      var self = this;
      var formData = new FormData();
      formData.append('media_list[attachment]', this.ui.fileInput[0].files[0]);
      this.ui.fileInput.val("");
      
      $.ajax({
        url: '/media_lists',
        data: formData,
        cache: false,
        contentType: false,
        processData: false,
        type: 'POST',
        dataType: 'JSON',
        success: function(res){
          var model = new Robin.Models.MediaList(res);
          
          self.collection.add(model);
          self.selectedMediaListsCollection.add(model, {
            pitchContactsCollection: self.pitchContactsCollection
          });
          
          $.growl({message: polyglot.t("smart_release.targets_step.media_tab.successfully_uploaded")
          },{
            type: 'success'
          });
          
          $.growl({message: polyglot.t("smart_release.targets_step.media_tab.ignored_contacts")
          },{
            type: 'info'
          });
        },
        error: function(res){
          if (res && res.responseJSON) {
            var errorField = _.keys(res.responseJSON)[0]
            var errorMessage = res.responseJSON[errorField][0];
            errorField = s.capitalize(errorField.replace(/_/g,' '));
            
            $.growl({message: errorField + ' ' + errorMessage
            },{
              type: 'danger'
            });
          }
        }
      });
    },
    fileUploadButtonClicked: function(e){
      e.preventDefault();
        
      if (Robin.user.get('can_create_media_list') != true) {
        $.growl({message: polyglot.t("smart_release.targets_step.media_tab.not_available")},
          {
            type: 'info'
          });
      } else {
        this.ui.fileInput.trigger("click");
      }
    }
  });
  
  ReleasesBlast.EmptyList = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/media-list/empty-list',
    tagName: 'tr'
  });

  ReleasesBlast.SelectedMediaListItemView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/media-list/selected-media-list-item',
    tagName: 'tr',
    model: Robin.Models.MediaList,
    ui: {
      deleteButton: 'a'
    },
    events: {
      "click @ui.deleteButton": "deleteButtonClicked"
    },
    initialize: function(options){
      this.pitchContactsCollection = options.pitchContactsCollection;
      this.parentCollection = options.parentCollection;
    },
    deleteRow: function(){
      this.parentCollection.remove(this.model, {
        pitchContactsCollection: this.pitchContactsCollection
      });
    },
    deleteButtonClicked: function(e){
      e.preventDefault();
      
      this.deleteRow();
    }
  });
  
  ReleasesBlast.SelectedMediaListsCompositeView = Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/media-list/selected-media-lists',
    collection: Robin.Collections.SelectedMediaLists,
    childView: ReleasesBlast.SelectedMediaListItemView,
    childViewContainer: 'tbody',
    tagName: "table",
    className: 'table table-condensed',
    emptyView: ReleasesBlast.EmptyList,
    childViewOptions: function() {
      return {
        pitchContactsCollection: this.pitchContactsCollection,
        parentCollection: this.collection
      };
    },
    initialize: function(options){
      this.pitchContactsCollection = options.pitchContactsCollection;
    }
  });
});
