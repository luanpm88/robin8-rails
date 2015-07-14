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
      'click #highlight_textarea': 'highlightReleaseText',
      'click #smart_release': 'startSmartRelease',
      'change #upload': 'uploadWord',
      'change #news_room_id': 'verifyPublic',
      'ifChanged .private-checkbox': 'changePrivate',
      'ifChanged .myprgenie-checkbox': 'switchMyprgenie',
      'ifChanged .accesswire-checkbox': 'switchAccesswire',
      'ifChanged .prnewswire-checkbox': 'switchPrnewswire',
      'click #make-public': 'makeNewsRoomPublic',
      'click #direct-image-upload': 'uploadDirectImage',
      'click #url-image-upload': 'uploadUrlImage',
      'click #direct-video-upload': 'uploadDirectVideo',
      'click #url-video-upload': 'uploadUrlVideo',
      'click #insert_link': 'insertLink',
    },
    insertLink: function(e) {
      var view = this;
      var url = prompt("Please paste you image's url");
      if (url) {
        var href_url = (url.match("^http://")) ? url : "http://" + window.location.host + "/" +url;
        window.setTimeout(function() {
          view.ui.wysihtml5.data('wysihtml5').editor.focus();
          view.ui.wysihtml5.data('wysihtml5').editor.composer.commands.exec("createLink", {href: href_url, target: '_blank'});
        }, 200);
      }
    },
    uploadDirectImage: function(e) {
      var view = this;
      uploadcare.openDialog(null, {
        tabs: 'file',
        multiple: false,
        imagesOnly: true
        }).done(function(file) {
            file.done(function(fileInfo) {
              view.ui.wysihtml5.data('wysihtml5').editor.focus();
              view.ui.wysihtml5.data('wysihtml5').editor.composer.commands.exec("insertImage", {src: fileInfo.originalUrl});
            });
        }).fail(function(error, fileInfo) {
            console.log(error);
        });
      return false;
    },
    uploadUrlImage: function(e) {
      var view = this;
      var url = prompt("Please paste you image's url");
      if(url){
        $.get( "/releases/img_url_exist?url=" + url, function( data ) {
          if (data) {
            window.setTimeout(function() {
              view.ui.wysihtml5.data('wysihtml5').editor.focus();
              view.ui.wysihtml5.data('wysihtml5').editor.composer.commands.exec("insertImage", {src: url});
            }, 200);
          }
          else{
            $.growl("Invalid url!", {
                type: "info",
            });
          }
        });
      }
    },
    uploadDirectVideo: function(e) {
      var view = this;
      uploadcare.openDialog(null, {
        tabs: 'file',
        inputAcceptTypes: 'video/*',
        multiple: false,
        }).done(function(file) {
          file.done(function(fileInfo) {
            view.ui.wysihtml5.data('wysihtml5').editor.focus();
            view.ui.wysihtml5.data('wysihtml5').editor.composer.commands.exec("insertHTML", "<video width="+550+" class='video-js vjs-default-skin' controls='auto' preload='auto' data-setup='{}'> <source src='" + fileInfo.originalUrl + "'></video>");
          });
        }).fail(function(error, fileInfo) {
          console.log(error);
        });
      return false;
    },
    uploadUrlVideo: function(e) {
      var view = this;
      var url = prompt("Please paste you video's url");
      if (url) {
        window.setTimeout(function() {
          view.ui.wysihtml5.data('wysihtml5').editor.focus();
          console.log(url);
          view.ui.wysihtml5.data('wysihtml5').editor.composer.commands.exec("insertVideo", url);
        }, 200);
      }
    },
    changePrivate: function(e) {
      // if ($(e.target).is(":checked")) {
      //   this.$el.find('.smart-release-button').addClass('disabled');
      // } else {
      //   this.$el.find('.smart-release-button').removeClass('disabled');
      // }
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
      this.releaseCharacteristicsModel = new Robin.Models.ReleaseCharacteristics;
      sweetAlertInitialize();
    },
    onRender: function(){
      var self = this;
      Robin.user = new Robin.Models.User();
      Robin.user.fetch({
        success: function() {
          self.verifyReleaseButton();
          if (Robin.user.get('can_create_smart_release') != true) {
            $('.smart-release-button').addClass('disabled-unavailable');
          } else {
            $('.smart-release-button').removeClass('disabled-unavailable');
          }
        }
      });
      this.newsrooms.fetch({
        success: function(data) {
          $.each(data.models ,function(index, newsroom){
            self.$el.find('#newsroom_filter').append('<option value="' + newsroom.get('id') + '">'+ newsroom.get('company_name') +'</option>');
            self.$el.find('#news_room_id').append('<option value="' + newsroom.get('id') + '">'+ newsroom.get('company_name') +'</option>');
          });
          self.$el.find('#newsroom_filter').prop("disabled",false);
          self.$el.find('#news_room_id').prop("disabled",false);
          self.modelBinder.bind(self.model, self.el);
        }
      });

      this.modelBinder.bind(this.model, this.el);
      this.initFormValidation();

      var date = moment(this.model.get('published_at')).toDate();
      var datedate = moment(date).format('MM/DD/YYYY');
      this.$el.find('#release-date-input').val(datedate).change();
      this.$el.find('#release-date-input').datetimepicker({format: 'MM/DD/YYYY'});

      this.$el.find('#myprgenie_date_input').datetimepicker({format: 'MM/DD/YYYY'});
      this.$el.find('#myprgenie_date_input').on('dp.change', function(e) {
        $('#releaseForm').formValidation('revalidateField', 'myprgenie_published_at');
      });

      this.$el.find('#accesswire_date_input').datetimepicker({format: 'MM/DD/YYYY'});
      this.$el.find('#accesswire_date_input').on('dp.change', function(e) {
        $('#releaseForm').formValidation('revalidateField', 'accesswire_published_at');
      });

      this.$el.find('#prnewswire_date_input').datetimepicker({format: 'MM/DD/YYYY'});
      this.$el.find('#prnewswire_date_input').on('dp.change', function(e) {
        $('#releaseForm').formValidation('revalidateField', 'prnewswire_published_at');
      });

      var insertLinkButton = this.$el.find('#wyihtml5-insert-link').html();
      var extractButtonTemplate = this.$el.find('#wyihtml5-extract-button').html();
      var extractWordTemplate = this.$el.find('#wyihtml5-word-button').html();
      var extractDirectImageTemplate = this.$el.find('#wyihtml5-direct-image-button').html();
      var extractDirectVideoTemplate = this.$el.find('#wyihtml5-direct-video-button').html();
      var customTemplates = {
        insert: function(context) {
          return insertLinkButton
        },
        extract: function(context) {
          return extractButtonTemplate
        },
        word: function(context) {
          return extractWordTemplate
        },
        directImage: function(context) {
          return extractDirectImageTemplate
        },
        directVideo: function(context) {
          return extractDirectVideoTemplate
        },
      };
      this.ui.wysihtml5.wysihtml5({
        toolbar: {
          insert: customTemplates.insert,
          extract: customTemplates.extract,
          word: customTemplates.word,
          directImage: customTemplates.directImage,
          directVideo: customTemplates.directVideo,
        },
        parserRules: {
          tags: {
                "b":  {},
                "i":  {},
                "br": {},
                "ol": {},
                "ul": {},
                "li": {},
                "h1": {},
                "h2": {},
                "h3": {},
                "h4": {},
                "h5": {},
                "h6": {},
                "video": {
                    "check_attributes": {
                        "controls": "any",
                        "preload": "any",
                        "class": "any",
                        "width": "any",
                    }},
                "source": {
                    "check_attributes": {
                        "src": "any", /* Needed for data:image/jpeg;base64 type */
                    }},
                "blockquote": {},
                "u": 1,
                "img": {
                    "check_attributes": {
                        "width": "numbers",
                        "alt": "alt",
                        "src": "any", /* Needed for data:image/jpeg;base64 type */
                        "height": "numbers",
                        "title": "alt"
                    }
                },
                "a":  {
                    check_attributes: {
                        'href': "src", // use 'url' to avoid XSS
                        'target': 'alt',
                        'rel': 'alt'
                    }
                },
                "iframe": {
                    "check_attributes": {
                        "src":"any",
                        "width":"numbers",
                        "height":"numbers"
                    },
                    "set_attributes": {
                        "frameborder":"0"
                    }
                },
                "p": 1,
                "span": 1,
                "div": 1,
                "table": 1,
                "tbody": 1,
                "thead": 1,
                "tfoot": 1,
                "tr": 1,
                "th": 1,
                "td": 1,
                // to allow save and edit files with code tag hacks
                "code": 1,
                "pre": 1,
                "style": 1
            }
        },
        'image': false,
        'video': false,
        'html': true,
        "blockquote": true,
        "table": false,
        "link": false,
        "textAlign": false
      });
      this.editor = this.ui.wysihtml5.data('wysihtml5').editor;
      this.editor.focus();
      this.editor.on('load', function() {
        self.updateStats();
        $('.wysihtml5-sandbox').contents().find('body').on('keyup keypress blur change focus', function(e) {
          self.updateStats()
        });
      });
      this.initLogoView();
      this.initMediaTab();
      if (Robin.newReleaseFromDashboard) {
        this.$el.find('#release_form').modal({keyboard: false });
        Robin.newReleaseFromDashboard = false;
      }
      this.$el.find("input[type='checkbox']").iCheck({
        checkboxClass: 'icheckbox_square-blue',
        increaseArea: '20%'
      });
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
      if(Robin.user.get('can_create_release') != true) {
        $.growl({message: "You don't have available releases!"},
          {
            type: 'info'
          });
      } else {
        this.model.clear();
        this.model.set(Robin.module("Releases").controller.filterCriteria);
        this.render();
        this.$el.find('#release_form').modal({ keyboard: false });
      }
    },
    openModalDialogEdit: function(data){
      this.model.set(data.toJSON().release);
      this.render();
      this.$el.find('#release_form').modal({ keyboard: false });
      this.verifyPublic(this.model.attributes.news_room.publish_on_website);
    },
    verifyPublic: function(publish) {
      var newsRoomId = $('#news_room_id').val();
      if (!!newsRoomId){
        selectedNewsroom = this.newsrooms.get(newsRoomId);
        publicNewsRoom = selectedNewsroom.attributes.publish_on_website;
      } else {
        publicNewsRoom = this.model.attributes.news_room_public;
      }
      if (publicNewsRoom) {
        this.$el.find('#public-alert').hide();
      } else {
        this.$el.find('#public-alert').show();
      }
    },
    makeNewsRoomPublic: function() {
      var newsRoomId = $('#news_room_id').val();
      var viewObj = this;
      if (newsRoomId != ""){
        selectedNewsroom = this.newsrooms.get(newsRoomId);
        selectedNewsroom.attributes.publish_on_website = true;
        selectedNewsroom.save(selectedNewsroom.attributes, {
            success: function(model, data, response){
              viewObj.$el.find('#public-alert').hide()
            },
            error: function(data, response){
              console.log(response);
            }
        });
      }
    },
    uploadWord: function(changeEvent) {
      var self = this;

      var formData = new FormData();
      $input = $('#upload');

      if (_.last($input[0].files[0].name.split('.')) != 'docx'){
        alert("Not supported file! Supported is *.docx");
        $input.replaceWith($input.val('').clone(true));
        return false;
      };

      formData.append('file', $input[0].files[0]);

      $.ajax({
        url: "/releases/extract_from_word",
        data: formData,
        cache: false,
        contentType: false,
        processData: false,
        dataType: 'json',
        type: 'POST',
        complete: function(response) {
          $.ajax({
            url: 'textapi/extract',
            dataType: 'json',
            method: 'POST',
            data: {
              html: response.responseText,
            },
            success: function(text) {
              self.parseResponseFromApi(text);
            }
          });
        }
      });
    },
    parseResponseFromApi: function(text) {
      var self = this;
      if (text != null) {
        self.model.set('title', text.title);
        var editor = self.ui.wysihtml5.data('wysihtml5').editor;
        editor.setValue( text.article.replace(/(\r\n|\n\r|\r|\n)/g, '</br>') );
      } else {
        alert("Something wrong with API");
      }
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
            if (response.title.length + response.article.length == 0) {
              swal({
                title: "Invalid link!",
                text: "The link you've provided is invalid or the site it leads to contains no usable information",
                type: "error",
                showCancelButton: false,
                confirmButtonClass: 'btn',
                confirmButtonText: 'ok'
              });
            } else if (response.article.length > 60000) {
              swal({
                title: "Provided release is too long",
                text:"Target page contains a text that exceeds the release length limit. The maximum is 60.000 characters (including spaces)",
                type: "error",
                showCancelButton: false,
                confirmButtonClass: 'btn',
                confirmButtonText: 'ok'
              });
            } else {
              var title = response.title.length==0 ? "undefined" : response.title;
              self.model.set('title', title);
              var editor = self.ui.wysihtml5.data('wysihtml5').editor;
              editor.setValue(response.article.replace(/(\r\n|\n\r|\r|\n)/g, '<br>'));
            }
            if (response.title.length > 0 || response.article.length > 0) {
              var title = response.title.length==0 ? "undefined" : response.title;
              self.model.set('title', title);
              var editor = self.ui.wysihtml5.data('wysihtml5').editor;
              editor.setValue(response.article.replace(/(\r\n|\n\r|\r|\n)/g, '<br>'));
            } else {
              swal({
                title: "Invalid link!",
                text: "The link you've provided is invalid or the site it leads to contains no usable information",
                type: "error",
                showCancelButton: false,
                confirmButtonClass: 'btn',
                confirmButtonText: 'ok'
              });
            }
          }
        });
      }
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
          },
          myprgenie_published_at: {
            validators: {
              callback: {
                message: 'Select correct date in future',
                callback: function(value, validator, $field) {
                  if( $('.myprgenie-checkbox').is(':checked') && $('#myprgenie_date_input').val() == '' ){
                    return false;
                  }

                  if( $('.myprgenie-checkbox').is(':checked') ) {
                    var now = moment().format("MM/DD/YYYY");
                    var myDate = new Date($('#myprgenie_date_input').val());
                    var myDate = moment($('#myprgenie_date_input').val(), 'MM/DD/YYYY')._i;
                    if(myDate < now){
                      return false;
                    }
                  }

                  return true;
                }
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          },
          accesswire_published_at: {
            validators: {
              callback: {
                message: 'Select correct date in future',
                callback: function(value, validator, $field) {
                  if( $('.accesswire-checkbox').is(':checked') && $('#accesswire_date_input').val() == '' ){
                    return false;
                  }

                  if( $('.accesswire-checkbox').is(':checked') ) {
                    var now = moment().format("MM/DD/YYYY");
                    var myDate = new Date($('#accesswire_date_input').val());
                    var myDate = moment($('#accesswire_date_input').val(), 'MM/DD/YYYY')._i;
                    if(myDate < now){
                      return false;
                    }
                  }

                  return true;
                }
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          },
          prnewswire_published_at: {
            validators: {
              callback: {
                message: 'Select correct date in future',
                callback: function(value, validator, $field) {
                  if( $('.prnewswire-checkbox').is(':checked') && $('#prnewswire_date_input').val() == '' ){
                    return false;
                  }

                  if( $('.prnewswire-checkbox').is(':checked') ) {
                    var now = moment().format("MM/DD/YYYY");
                    var myDate = new Date($('#prnewswire_date_input').val());
                    var myDate = moment($('#prnewswire_date_input').val(), 'MM/DD/YYYY')._i;
                    if(myDate < now){
                      return false;
                    }
                  }

                  return true;
                }
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
    startSmartRelease: function(options){
      if (Robin.user.get('can_create_smart_release') != true) {
        $.growl({message: "You don't have available smart-releases!"},
          {
            type: 'info'
          });
      } else {
        if (this.form.data('formValidation') == undefined) {
          this.initFormValidation();
        }
        var viewObj = this;
        this.modelBinder.copyViewValuesToModel();
        var iframe = document.getElementsByClassName("wysihtml5-sandbox");
        if ( $(iframe).contents().find('body').html() !== 'Paste your press release here...' ) {
          this.model.set('text', $(iframe).contents().find('body').html());
        };
        this.form.data('formValidation').validate();
        var textLength = this.$el.find('iframe').contents().find('.wysihtml5-editor').html().length;
        if (textLength > 60000) {
          swal({
            title: "Release text is too long!",
            text: "Relase text should not exceed 60.000 characters (including spaces and hidden HTML)",
            type: "error",
            showCancelButton: false,
            confirmButtonClass: 'btn',
            confirmButtonText: 'ok'
          });
        }
        if (this.form.data('formValidation').isValid() && textLength <= 60000) {
          this.$el.find('#save_release').prop("disabled",true);
          this.$el.find('#smart_release').prop("disabled",true);

          this.model.attributes.published_at = moment(this.model.attributes.published_at, 'MM/DD/YYYY').format('LL');
          this.model.attributes.myprgenie_published_at = moment(this.model.attributes.myprgenie_published_at, 'MM/DD/YYYY').format('LL');
          this.model.attributes.accesswire_published_at = moment(this.model.attributes.accesswire_published_at, 'MM/DD/YYYY').format('LL');
          this.model.attributes.prnewswire_published_at = moment(this.model.attributes.prnewswire_published_at, 'MM/DD/YYYY').format('LL');

          this.model.save(viewObj.model.attributes, {
            success: function(model, data, response){
              viewObj.$el.find('#release_form').modal('hide');
              $('body').removeClass('modal-open');
              $('.modal-backdrop').remove();
              Robin.releaseForBlast = viewObj.model.get('id');
              Backbone.history.navigate('robin8', {trigger: true});
            },
            error: function(data, response){
              viewObj.processErrors(response);
            }
          });
        }
      }
    },
    saveRelease: function(e){
      if (this.form.data('formValidation') == undefined) {
        this.initFormValidation();
      }
      var viewObj = this;
      this.modelBinder.copyViewValuesToModel();
      var iframe = document.getElementsByClassName("wysihtml5-sandbox");
      if ( $(iframe).contents().find('body').html() !== 'Paste your press release here...' ) {
        this.model.set('text', $(iframe).contents().find('body').html());
      };
      this.form.data('formValidation').validate();
      var textLength = this.$el.find('iframe').contents().find('.wysihtml5-editor').html().length;
      if (textLength > 60000) {
        swal({
          title: "Release text is too long!",
          text: "Relase text should not exceed 60.000 characters (including spaces and hidden HTML)",
          type: "error",
          showCancelButton: false,
          confirmButtonClass: 'btn',
          confirmButtonText: 'ok'
        });
      }
      if (this.form.data('formValidation').isValid() && textLength <= 60000) {
        this.$el.find('#save_release').prop("disabled",true);
        this.$el.find('#smart_release').prop("disabled",true);

        this.model.attributes.published_at = moment(this.model.attributes.published_at, 'MM/DD/YYYY').format('LL');
        this.model.attributes.myprgenie_published_at = moment(this.model.attributes.myprgenie_published_at, 'MM/DD/YYYY').format('LL');
        this.model.attributes.accesswire_published_at = moment(this.model.attributes.accesswire_published_at, 'MM/DD/YYYY').format('LL');
        this.model.attributes.prnewswire_published_at = moment(this.model.attributes.prnewswire_published_at, 'MM/DD/YYYY').format('LL');
        if (this.model.attributes.id) {
          this.model.save(this.model.attributes, {
            success: function(model, data, response){
              Robin.user.fetch({
                success: function() {
                  viewObj.verifyReleaseButton();
                }
              });
              viewObj.$el.find('#release_form').modal('hide');
              $('body').removeClass('modal-open');
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
              Robin.user.fetch({
                success: function() {
                  viewObj.verifyReleaseButton();
                }
              });
              viewObj.$el.find('#release_form').modal('hide');
              $('body').removeClass('modal-open');
              $('.modal-backdrop').remove();
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
              viewObj.render();
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
    verifyReleaseButton: function() {
      if(Robin.user.get('can_create_release') != true) {
        $('button#new_release').addClass('disabled-unavailable');
      } else {
        $('button#new_release').removeClass('disabled-unavailable');
      }
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
              Robin.user.fetch({
                success: function() {
                  viewObj.verifyReleaseButton();
                }
              });
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
    },
    switchMyprgenie: function(e){
      $('#releaseForm').formValidation('revalidateField', 'myprgenie_published_at');
      if ($(e.target).is(":checked")) {
        if(!Robin.user.get('can_create_myprgenie')){
          $.growl("Please, buy corresponding addon in Billing settings!", {
            type: "info",
          });
          setTimeout(function(){ $(e.target).iCheck('uncheck'); }, 1);
          return;
        }
        $('#myprgenie_start_div').show();
      }
      else {
        $('#myprgenie_date_input').val('');
        $('#myprgenie_start_div').hide();
      }
    },
    switchAccesswire: function(e){
      $('#releaseForm').formValidation('revalidateField', 'accesswire_published_at');
      if ($(e.target).is(":checked")) {
        if(!Robin.user.get('can_create_accesswire')){
          $.growl("Please, buy corresponding addon in Billing settings!", {
            type: "info",
          });
          setTimeout(function(){ $(e.target).iCheck('uncheck'); }, 1);
          return;
        }
        $('#accesswire_start_div').show();
      }
      else {
        $('#accesswire_date_input').val('');
        $('#accesswire_start_div').hide();
      }
    },
    switchPrnewswire: function(e){
      $('#releaseForm').formValidation('revalidateField', 'prnewswire_published_at');
      if ($(e.target).is(":checked")) {
        if(!Robin.user.get('can_create_prnewswire')){
          $.growl("Please, buy corresponding addon in Billing settings!", {
            type: "info",
          });
          setTimeout(function(){ $(e.target).iCheck('uncheck'); }, 1);
          return;
        }
        $('#prnewswire_start_div').show();
      }
      else {
        $('#prnewswire_date_input').val('');
        $('#prnewswire_start_div').hide();
      }
    }
  });
});
