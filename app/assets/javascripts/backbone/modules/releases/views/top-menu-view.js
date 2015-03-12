Robin.module('Releases', function(Releases, App, Backbone, Marionette, $, _){

  Releases.TopMenuView = Marionette.LayoutView.extend({
    template: 'modules/releases/templates/top-menu-view',
    className: 'row',
    regions: {
      logoRegion: '.logo',
      imagesRegion: '.images_region',
      videosRegion: '.videos_region',
      filesRegion: '.files_region',
      characteristicsRegion: '#release-characteristics'
    },
    ui: {
      wysihtml5:        'textarea.wysihtml5',
      releaseTitle:     '#release-title-input',
    },
    events: {
      'click #new_release': 'openModalDialog',
      'click #newsroom_filter': 'filterBy',
      'click #save_release': 'saveRelease',
      'click #delete_release': 'deleteRelease',
      'click #extract_url': 'extractURL',
      'click #highlight_textarea': 'highlightReleaseText'
    },
    highlightReleaseText: function(e) {
      e.preventDefault();
    },
    updateStats: _.debounce(function(e) {
      var html = this.editor.getValue();
      // strip HTML tags before parsing text
      var div = document.createElement("div");
      div.innerHTML = html;
      var text = div.textContent || div.innerText || "";
      var words = new Lexer().lex(text);
      var taggedWords = new POSTagger().tag(words);
      var numberOfNonSpaceCharacters = text.replace(/\W*/mg, '').length;
      var poses = _.chain(taggedWords).reject(function(w) {
        return w[1].match(/^[,.]$/)
      }).countBy(function(w) { return w[1].slice(0, 2); }).value();
      var sentences = _(text.match(/[^.!?]+(\.!\?)?/g) || []).filter(function(s) {
        return s.length > 5;
      });
      this.releaseCharacteristicsModel.set({
        numberOfNouns: poses.NN || 0,
        numberOfAdverbs: poses.RB || 0,
        numberOfAdjectives: poses.JJ || 0,
        numberOfCharacters: text.length,
        numberOfWords: words.length,
        numberOfSentences: sentences.length,
        numberOfNonSpaceCharacters: numberOfNonSpaceCharacters,
        numberOfParagraphs: words.length === 0 ? 0 : text.split(/\n+/).length,
      });
      // set these in a separate batch becaue they rely on above set()
      // mutates the model.
      this.releaseCharacteristicsModel.set({
        readabilityScoreTitle: this.releaseCharacteristicsModel.getReadabilityScoreTitle(),
        readabilityScore: this.releaseCharacteristicsModel.getReadabilityScore()
      });
    }, 500),
    initialize: function(options){
      var viewObj = this;
      this.modelBinder = new Backbone.ModelBinder();
      Robin.vent.on("release:open_edit_modal", this.openModalDialogEdit, this);
      this.newsrooms = new Robin.Collections.NewsRooms();
      this.newsrooms.fetch();
      this.releaseCharacteristicsModel = new Robin.Models.ReleaseCharacteristics;
    },
    filterBy: function(options){
      Robin.module("Releases").controller.index({
        by_news_room: options.target.value,
        page: Robin.module("Releases").controller.page,
        per_page: Robin.module("Releases").controller.per_page
      });
    },
    templateHelpers: function () {
      return {
        newsrooms: this.newsrooms
      };
    },
    openModalDialog: function(){
      this.model.clear();
      this.model.set(Robin.module("Releases").controller.filterCriteria);
      this.render();
      this.$el.find('#release_form').modal({ keyboard: false });
    },
    openModalDialogEdit: function(data){
      this.model.set(data.toJSON().release);
      this.render();
      this.$el.find('#release_form').modal({ keyboard: false });
    },
    extractURL: function(e) {
      var url = prompt("Enter a link to grab the press release from:", "");
      var self = this;
      if (url) {
        $.ajax({
          url: 'textapi/extract',
          dataType: 'json',
          method: 'POST',
          data: {
            url: url
          },
          success: function(response) {
            self.ui.releaseTitle.val(response.title);
            var editor = self.ui.wysihtml5.data('wysihtml5').editor;
            editor.setValue(
              '<p>' + response.article.replace(/(\r\n|\n\r|\r|\n)/g, '</p><p>') + '</p>'
            );
          }
        });
      }
    },
    onRender: function(){
      this.modelBinder.bind(this.model, this.el);
      this.initFormValidation();
      var extractButtonTemplate = this.$el.find('#wyihtml5-extract-button').html();
      var customTemplates = {
        extract: function(context) {
          return extractButtonTemplate
        }
      };
      this.ui.wysihtml5.wysihtml5({
        toolbar: {
          extract: true
        },
        customTemplates: customTemplates,
      });
      var self = this;
      this.editor = this.ui.wysihtml5.data('wysihtml5').editor;
      this.editor.on('load', function() {
        $('.wysihtml5-sandbox').contents().find('body').on('keyup keypress blur change focus', function(e) {
          self.updateStats()
        });
      });
      this.initLogoView();
      this.initMediaTab();
    },
    initLogoView: function(){
      this.logoRegion.show(new Robin.Views.LogoView({
        model: this.model,
        field: 'logo_url'
      }));
    },
    initMediaTab: function(){
      this.imagesRegion.show(new Robin.Views.ImagesCollectionView({
        model: this.model,
        collection: new Robin.Collections.Attachments(),
        childView: Robin.Views.ImagesItemView
      }));
      this.videosRegion.show(new Robin.Views.VideosCollectionView({
        model: this.model,
        collection: new Robin.Collections.Attachments(),
        childView: Robin.Views.VideosItemView
      }));
      this.filesRegion.show(new Robin.Views.FilesCollectionView({
        model: this.model,
        collection: new Robin.Collections.Attachments(),
        childView: Robin.Views.FilesItemView
      }));
      this.characteristicsRegion.show(new Releases.CharacteristicsView({
        model: this.releaseCharacteristicsModel
      }));
    },
    initFormValidation: function(){
      this.form = $('#releaseForm').formValidation({
        framework: 'bootstrap',
        excluded: [':disabled'],
        icon: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
          title: {
            validators: {
              notEmpty: {
                message: 'The Title is required'
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          },
          news_room_id: {
            validators: {
              notEmpty: {
                message: 'You should select a newsroom'
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          }
        }
      })
      .on('err.field.fv', function(e, data) {
        // data.element --> The field element
        var $tabPane = data.element.parents('.tab-pane'),
          tabId    = $tabPane.attr('id');
        $('a[href="#' + tabId + '"][data-toggle="tab"]')
          .addClass('error-tab');
      })
        // Called when a field is valid
      .on('success.field.fv', function(e, data) {
          // data.fv      --> The FormValidation instance
          // data.element --> The field element
        var $tabPane = data.element.parents('.tab-pane'),
          tabId    = $tabPane.attr('id');
        $('a[href="#' + tabId + '"][data-toggle="tab"]')
          .removeClass('error-tab');
      });
    },
    saveRelease: function(e){
      var viewObj = this;
      var iframe = document.getElementsByClassName("wysihtml5-sandbox");
      if ( $(iframe).contents().find('body').html() !== 'Paste your press release here...' ) {
        this.model.set('text', $(iframe).contents().find('body').html());
      };
      this.form.data('formValidation').validate();
      if (this.form.data('formValidation').isValid()) {
        if (this.model.attributes.id) {
          this.model.save(this.model.attributes, {
            success: function(model, data, response){
              viewObj.$el.find('#release_form').modal('hide');
              Robin.module("Releases").collection.add(data, {merge: true});
              Robin.module("Releases").collection.trigger('reset');
            },
            error: function(data, response){
              viewObj.processErrors(response);
            }
          });
        }else{
          this.model.save(this.model.attributes, {
            success: function(model, data, response){
              viewObj.$el.find('#release_form').modal('hide');
              if (Robin.module("Releases").controller.filterCriteria.page == 1) {
                if (Robin.module("Releases").collection.length == Robin.module("Releases").controller.filterCriteria.per_page) {
                  Robin.module("Releases").collection.pop();
                }
                Robin.module("Releases").collection.unshift(data);
                Robin.module("Releases").pagination_view.model.set({
                  page: Robin.module("Releases").controller.filterCriteria.page,
                  per_page:  Robin.module("Releases").controller.filterCriteria.per_page,
                  total_count: parseInt(response.xhr.getResponseHeader('Totalcount'),10),
                  total_pages: parseInt(response.xhr.getResponseHeader('Totalpages'),10)
                });
              }
            },
            error: function(data, response){
              viewObj.processErrors(response);
            }
          });
        }
      }
    },
    processErrors: function(data){
      var errors = JSON.parse(data.responseText).errors;
      _.each(errors, function(value, key){
        this.form.data('formValidation').updateStatus(key, 'INVALID', 'serverError')
        this.form.data('formValidation').updateMessage(key, 'serverError', value.join(','))
      }, this);
    },
    deleteRelease: function(){
      var viewObj = this;
      swal({
        title: "Remove this release?",
        text: "You will not be able to recover this release.",
        type: "error",
        showCancelButton: true,
        confirmButtonClass: 'btn-danger',
        confirmButtonText: 'Delete'
      },
      function(isConfirm) {
        if (isConfirm) {
          viewObj.model.destroy({
            success: function(model, response){
              viewObj.$el.find('#release_form').modal('hide');
              var page = Robin.module("Releases").controller.filterCriteria.page;
              if(Robin.module("Releases").collection.length == 1 && page > 1 || page == 1) {
                Robin.module("Releases").controller.paginate(1);
              }else {
                Robin.module("Releases").controller.paginate(page);
              }
            },
            error: function(data){
              console.warn('error', data);
            }
          });
        }
      });
    },
    onDestroy: function(){
      Robin.vent.off("release:open_edit_modal", this.openModalDialogEdit);
      this.modelBinder.unbind();
    }
  });
});
