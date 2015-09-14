Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.StreamCompositeView = Backbone.Marionette.CompositeView.extend({
    template: 'modules/monitoring/show/templates/monitoring_stream',
    tagName: "li",
    className: "stream",
    childViewContainer: ".stories",
    ui: {
      exportButton: ".export-button",
      exportDialog: ".export-dialog",
      setAlertButton: ".set-alert-button",
      setAlertDialog: ".set-alert-dialog",
      storiesNumberSlider: "input.stories-number",
      storiesNumberOutput: "#stories-number",
      colorizeBackground: ".export-dialog [name=colorize-background]",
      formatFileInput: ".export-dialog [name=format]",
      downloadReportButton: "#download-report",
      dateRangeField: "input[name=daterange]",
      emailAlertField: ".set-alert-dialog input[name=email]",
      phoneAlertField: ".set-alert-dialog input[name=phone]",
      enabledAlertCheckbox: ".set-alert-dialog input[name=enabled]",
      saveAlertButton: ".set-alert-dialog button[type=submit]"
    },
    events: {
      'click .delete-stream': 'closeStream',
      'click .settings-button': 'settings',
      'click .rss-button': 'toggleRssDialog',
      'click @ui.exportButton': 'exportButtonClicked',
      'click @ui.setAlertButton': 'setAlertButtonClicked',
      'change @ui.storiesNumberSlider': 'storiesNumberSliderChanged',
      'click @ui.downloadReportButton': "downloadReportButtonClicked",
      'change @ui.formatFileInput': "formatFileInputChanged",
      'click #close-settings': 'closeSettings',
      'click #done': 'done',
      'click span.editable': 'editTitle',
      'click .editable-submit': 'updateTitle',
      'click .js-show-new-stories': 'showNewStories',
      'click .rss-input': 'selectLink',
      'click .make-keyword': 'makeKeyword',
      'click @ui.saveAlertButton': 'saveAlertButtonClicked'
    },

    collectionEvents: {
      add: 'onAdded',
      'reset': 'afterFetch',
      'sync': 'afterFetch',
      'request': 'showLoading',
    },

    modelEvents: {
      change: 'setShowUpdatesButtonVisibility',
      'change:sort_column': 'refreshTimeRangeVisibility'
    },

    showLoading: function (e) {
      this.$el.find('.stream-loading').removeClass('hidden');
      this.$el.find('.empty-stream').addClass('hidden');
    },

    afterFetch: function (e) {
      this.filterCollection();
      this.$el.find('.stream-loading').addClass('hidden');
      this.$el.find('.stream-body').removeClass('opacity-02');
      if (this.collection.length != 0) {
        this.$el.find('.empty-stream').addClass('hidden');
      } else {
        this.$el.find('.empty-stream').removeClass('hidden');
      };
    },

    makeKeyword: function (e) {
      var view = this;
      var topics = this.model.get('topics');
      var getKeywords = this.model.get('keywords') == undefined ? [] : this.model.get('keywords');;
      view.model.set('topics', [])

      $.each(topics, function( index, topic ) {
        var new_keyword = topic.text.replace(/\W/gi, ' ').split(' ');
        $.each(new_keyword, function( index, key ) {
          if (key.length > 0) {
            var newValue = {
              id: key,
              text: key,
              type: 'keyword'
            };
            getKeywords.push(newValue);
          }
        });

      });
      view.model.set('keywords', getKeywords);
      view.model.save( view.model.attributes, {
        success: function(userSession, response){
          view.collection.streamId = response.id;
          view.collection.fetch({reset: true});
          Robin.loadingStreams.push(view.collection.streamId);

          Robin.cachedStories[response.id] = view.collection;
          Robin.cachedStories[response.id].sortByPopularity = view.model.get('sort_column') == 'shares_count';

          $.growl({message: polyglot.t("monitoring.messages.topics_saved_as_keywords")
          },{
            type: 'success'
          });
          Robin.cachedStories[view.model.get('id')].alreadyRendered = false;
          view.render();
        },
        error: function(data){
          console.warn('error', data);
        }
      });
      view.$el.find('.stream-loading').removeClass('hidden');
      view.$el.find('.empty-stream').addClass('hidden');
    },

    filterCollection: function () {
      var initArray = this.collection.models;
      var deleteList = [];
      var ViewObj = this;

      initArray.forEach(function(model) {
        var title = model.attributes.title;
        deleteResult = $.grep(initArray, function(e){
          return ((e.attributes.title == model.attributes.title) && (e.attributes.id != model.attributes.id))
        });
        initArray = $.grep(initArray, function(e){
          return !((e.attributes.title == model.attributes.title) && (e.attributes.id != model.attributes.id))
        });
        if (deleteResult.length > 0) {
          var id = deleteResult[0].attributes.id ;
          var itemToDelete = ViewObj.collection.get(id);
          ViewObj.collection.remove(itemToDelete);
        }
      });
    },

    selectLink: function (e) {
      $(e.target).select();
    },

    templateHelpers: function () {
      return {
        topicsForRss: function(){
          if (this.stream && this.stream.topics) {
            var arr = this.stream.topics;
            var str = _.pluck(arr.slice(0,3), 'text').join(',');
            return arr.length > 3 ? (str+'...') : str
          }
        },
        blogsForRss: function(){
          if (this.stream && this.stream.blogs) {
            var arr = this.stream.blogs;
            var str = _.pluck(arr.slice(0,3), 'text').join(',');
            return arr.length > 3 ? (str+'...') : str
          }
        }
      };
    },

    initialize: function() {
      var self = this;
      
      this.modelBinder = new Backbone.ModelBinder();
      this.alertModel = new Robin.Models.Alert();
      
      // id of the alerts resource is not important cause 
      // each stream has just one alert 
      this.alertModel.fetch({ 
        url: '/alerts/12',
        data: {
          stream_id: self.model.get('id')
        },
        success: function(model, response, options){
          self.alertModel = model;
          self.render();
        }
      });
      
      var streamId = this.model.get('id');

      if (streamId && !Robin.cachedStories[streamId]) {
        Robin.loadingStreams.push(streamId);

        Robin.cachedStories[streamId] = new Robin.Collections.Stories();
        Robin.cachedStories[streamId].streamId = streamId;
        Robin.cachedStories[streamId].alreadyRendered = false;
        Robin.cachedStories[streamId].sortByPopularity = this.model.get('sort_column') == 'shares_count';
      }

      this.collection = Robin.cachedStories[streamId] || new Robin.Collections.Stories();
      if (Robin.loadingStreams.length == 1) {
        Robin.currentStreamIndex = 0;
        this.collection.executePolling();
      }

      this.refreshNewStoriesCount();

      this.childView = Show.StoryItemView;
    },
    updateAlertDialog: function(){
      this.ui.emailAlertField.val(this.alertModel.get('email'));
      this.ui.phoneAlertField.val(this.alertModel.get('phone'));
      
      if (this.alertModel.get('enabled'))
        this.ui.enabledAlertCheckbox.prop('checked', true);
      else
        this.ui.enabledAlertCheckbox.prop('checked', false);
    },
    onRender: function() {
      var curView = this;
      
      Robin.user.fetch({
        success: function() {
          if (Robin.user.get('can_create_stream') != true) {
            curView.$el.find("#add-stream").addClass('disabled-unavailable');
          } else {
            curView.$el.find("#add-stream").removeClass('disabled-unavailable');
          }
        }
      });
      this.$el.attr("data-pos",this.model.id)
      $.fn.editable.defaults.mode = 'inline';
      this.$el.find('span.editable').editable({inputclass: 'edit-title'});
      this.loadInfo('topics');
      this.loadInfo('blogs');
      this.modelBinder.bind(this.model, this.el);

      if (Robin.cachedStories[this.model.get('id')] != undefined) {
        if (Robin.cachedStories[this.model.get('id')].length > 0){
          this.$el.find('.stream-loading').addClass('hidden');
        } 
        
        if (Robin.cachedStories[this.model.get('id')].alreadyRendered && Robin.cachedStories[this.model.get('id')].length == 0) {
          this.$el.find('.stream-loading').addClass('hidden');
          this.$el.find('.empty-stream').removeClass('hidden');
        }
        Robin.cachedStories[this.model.get('id')].alreadyRendered = true;
      }

      if (this.needOpacity) {
        this.$el.find('.stream-loading').removeClass('hidden');
        this.$el.find('.stream-body').addClass('opacity-02');
      }

      if (!this.model.get('id')) {
        this.$el.find('.stream-loading').addClass('hidden');
        this.$el.find('.settings-dialog').removeClass('closed');
      } 

      this.$el.find('[data-toggle=tooltip]').tooltip({trigger:'hover'});
      this.$el.find('.stream-body').on('scroll', this.checkScroll(this));

      this.refreshTimeRangeVisibility();
      this.$el.find("input.select2-input").css('width', '150%');

      
      this.ui.colorizeBackground.prop('checked', true);
      this.ui.colorizeBackground.parent().hide();
      this.ui.formatFileInput.val('docx').trigger('change');
      this.initDateRangeField();
      this.updateAlertDialog();
    },
    initDateRangeField: function(){
      this.ui.dateRangeField.daterangepicker({
        ranges: {
          'Last 24 Hours': [moment().subtract(1, 'days'), new Date()],
          'Last 7 Days': [moment().subtract(6, 'days'), new Date()],
          'Last 30 Days': [moment().subtract(29, 'days'), new Date()],
          'This Month': [moment().startOf('month'), moment().endOf('month')],
          'Last Month': [moment().subtract(1, 'month').startOf('month'), 
            moment().subtract(1, 'month').endOf('month')]
        },
        opens: 'right'
      });
    },
    onAdded: function(story, collection) {
      this.filterCollection();
      this.refreshNewStoriesCount();
      this.setShowUpdatesButtonVisibility();
    },

    editTitle: function() {
      this.$el.find('.edit-title').attr('name', 'name')
      this.modelBinder.bind(this.model, this.el);
    },

    updateTitle: function() {
      this.modelBinder.copyViewValuesToModel();
      this.model.save(this.model.attributes, {
        success: function(data){
          console.log(data);
        },
        error: function(data){
          console.warn('error', data);
        }
      });
    },

    loadInfo: function(val) {
      var currentModel = this.model;
      var currentValue = '';
      var currentView = this;

      $(this.el).find('#' + val + '-select').select2({
        multiple: true,
        tags: true,
        ajax: {
          url: '/autocompletes/' + val,
          dataType: 'json',
          data: function(term, page) { 
            currentValue = term;
            return { term: term } 
          },
          results: function(data, page) { 
            if (data.length > 3) {
              data.splice(0, 1);
            } 
            if (val == 'topics') {
              newValue = {
                id: currentValue,
                text: 'Add ' + currentValue + ' as keyword',
                type: 'keyword'
              };
              data.unshift(newValue);
            }
            return { results: data }; 
          }
        },
        initSelection : function (element, callback) {
          if (val == 'topics') {
            callback(currentModel.attributes[val].concat(currentModel.attributes['keywords']));
          } else {
            callback(currentModel.attributes[val]);
          }
        },
        minimumInputLength: 1,
      }).on("select2-selecting", function(e) {
        if ( _.where(currentModel.attributes.topics, e.object).length > 0){
          e.preventDefault()
          $.growl("You have already select this item!", {
            type: "success",
          });
        } else {
          if (e.object.type == 'keyword' && val == 'topics') {
            var getKeyword = currentModel.get('keywords') == undefined ? [] : currentModel.get('keywords');;
            var newValue = {
              id: e.val,
              text: e.val,
              type: 'keyword'
            };
            getKeyword.push(newValue);
            currentModel.set('keywords', getKeyword);
            e.object.text = e.object.id
          } else {
            var getTopics = currentModel.get(val) == undefined ? [] : currentModel.get(val);;
            var newValue = {
              id: e.val,
              text: e.object.text
            };
            getTopics.push(newValue);
            currentModel.set(val, getTopics);
          }
        }
      }).on("select2-removed", function(e) {
        if (e.choice.type == 'keyword' && val == 'topics') {
          var getKeywords = currentModel.get('keywords') == undefined ? [] : currentModel.get('keywords');
          var updatedKeywords = _.reject(getKeywords, function(k){ return k.id == e.val; });

          currentModel.set('keywords', updatedKeywords);
        } else {
          var getTopics = currentModel.get(val) == undefined ? [] : currentModel.get(val);;
          var updatedTopics = _.reject(getTopics, function(k){ return k.id == e.val; });

          currentModel.set(val, updatedTopics);
        }
      });
      $(this.el).find('#' + val + '-select').select2('val', currentModel.attributes[val]);
    },

    closeStream: function() {
      var curView = this;
      var r = this.model;
      var modelId = r.id;
      if(!r.get('id')) return r.destroy({
        dataType: "text",
        success: function() {
          Robin.user.fetch({
            success: function() {
              if (Robin.user.get('can_create_stream') != true) {
                $("#add-stream").addClass('disabled-unavailable');
              } else {
                $("#add-stream").removeClass('disabled-unavailable');
              }
            }
          });
        }
      });
      swal({
        title: polyglot.t("monitoring.messages.delete_stream"),
        text: polyglot.t("monitoring.messages.not_able_recover"),
        type: "error",
        showCancelButton: true,
        confirmButtonClass: 'btn-danger',
        confirmButtonText: 'Delete'
      },
      function(isConfirm) {
        if (isConfirm) {
          r.destroy({ 
            dataType: "text",
            success: function() {
              var index = Robin.loadingStreams.indexOf(modelId);
              if (index > -1) {
                Robin.loadingStreams.splice(index, 1);
              } 

              Robin.user.fetch({
                success: function() {
                  if (Robin.user.get('can_create_stream') != true) {
                    $("#add-stream").addClass('disabled-unavailable');
                  } else {
                    $("#add-stream").removeClass('disabled-unavailable');
                  }
                }
              });
            }
          });
        }
      });
    },
    setAlertButtonClicked: function(e){
      this.ui.setAlertDialog.toggleClass('closed');
    },
    errorFields: {
      "email": "Email",
      "phone": "Phone number",
      "enabled": "Enable",
      "stream_id": "Stream",
      "email_and_phone": "Email or Phone number"
    },
    saveAlertButtonClicked: function(e){
      e.preventDefault();
      
      var self = this;
      
      var streamId = this.model.id;
      var email = this.ui.emailAlertField.val();
      var phone = this.ui.phoneAlertField.val();
      var enabled = this.ui.enabledAlertCheckbox.prop('checked');
      
      this.alertModel.set('email', email);
      this.alertModel.set('phone', phone);
      this.alertModel.set('enabled', enabled);
      this.alertModel.set('stream_id', streamId);
      
      this.alertModel.save({}, { 
        success: function(model, response, options){
          self.ui.setAlertDialog.toggleClass('closed');
          var sort_column = self.model.get('sort_column');
          
          if (sort_column == "published_at"){
            $.growl({message:  polyglot.t("monitoring.messages.alert_saved")
            },{
              type: 'success'
            });
          } else {
            $.growl({message:  polyglot.t("monitoring.messages.alert_saved_not_sorted")
            },{
              type: 'warning'
            });
          }
        },
        error: function(model, response, options){
          _(response.responseJSON).each(function(val, key){
            $.growl({message: self.errorFields[key] + ' ' + val[0]
            },{
              type: 'danger'
            });
          });
        }
      });
    },
    exportButtonClicked: function(e){
      this.ui.exportDialog.toggleClass('closed');
    },
    storiesNumberSliderChanged: function(e){
      currentValue = this.ui.storiesNumberSlider.val();
      this.ui.storiesNumberOutput.val(currentValue);
    },
    downloadReportButtonClicked: function(e){
      e.preventDefault();
      
      this.downloadReport();
    },
    formatFileInputChanged: function(e){
      var fileFormat = this.ui.formatFileInput.val();
      
      if (fileFormat === "docx")
        this.ui.colorizeBackground.parent().hide();
      else
        this.ui.colorizeBackground.parent().show();
    },
    downloadReport: function(){
      var numberOfStories = this.ui.storiesNumberSlider.val();
      var streamId = this.model.id;
      var format = this.ui.formatFileInput.val();
      var colorizeBackground = null;
      var dateRange = this.ui.dateRangeField.val();
      var published_at = null;
      
      if (!s.isBlank(dateRange)){
        published_at = "[" + _(dateRange.split('-')).map(function(i){ 
          return new Date(i.trim()).toISOString() 
        }).join(' TO ') + "]";
      }
      
      if (this.ui.colorizeBackground.is(":checked"))
        colorizeBackground = true
      else
        colorizeBackground = false
      
      var params = {
        colorize_background: colorizeBackground, 
        per_page: numberOfStories
      };
      
      if (published_at)
        params['published_at'] = published_at
        
      openWindow('GET', '/streams/' + streamId + '/stories.' + format, params);
    },
    toggleRssDialog: function(){
      $(this.el).find('.rss-dialog').toggleClass('closed');
    },

    settings: function() {
      $(this.el).find('.settings-dialog').toggleClass('closed');
    },

    closeSettings: function(e) {
      e.preventDefault();
      $(this.el).find('.settings-dialog').addClass('closed');
      if(!this.model.get('id')) this.closeStream();
    },

    done: function(e) {
      e.preventDefault();

      var curView = this;

      this.model.save(this.model.attributes, {
        success: function(userSession, response) {
          Robin.user.fetch({
            success: function() {
              if (Robin.user.get('can_create_stream') != true) {
                $("#add-stream").addClass('disabled-unavailable');
              } else {
                $("#add-stream").removeClass('disabled-unavailable');
              }
            }
          });
          curView.collection.streamId = response.id;
          curView.collection.fetch({reset: true});
          Robin.loadingStreams.push(curView.collection.streamId);

          Robin.cachedStories[response.id] = curView.collection;
          Robin.cachedStories[response.id].sortByPopularity = curView.model.get('sort_column') == 'shares_count';

          $(curView.el).attr("data-pos",response.id);
          $(curView.el).find('.settings-dialog').addClass('closed');
          $.growl({message: polyglot.t("monitoring.messages.stream_saved")
          },{
            type: 'success'
          });
          Robin.cachedStories[curView.model.get('id')].alreadyRendered = false;
          curView.render();
        },
        error: function(userSession, response) {
          var result = $.parseJSON(response.responseText);
          _(response.responseJSON).each(function(errors,field) {
            _(errors).each(function(error, i) {
              formatted_field = s(field).capitalize().value().replace('_', ' ');
              $.growl({title: '<strong>' + formatted_field + ':</strong> ',
                message: error
              }, {
                type: "danger",
              });
            });
          });
        }
      });

      curView.$el.find('.stream-loading').removeClass('hidden');
      curView.$el.find('.stream-body').addClass('opacity-02');
      curView.$el.find('.empty-stream').addClass('hidden');
      curView.needOpacity = true;
      $(this.el).find('.settings-dialog').addClass('closed');
    },

    showNewStories: function() {
      this.collection.where({isNew: true}).forEach(function(story) {
        story.set('isNew', false);
      });
      this.model.set('newStoriesCount', 0);
      this.collection.refreshInitialFetchAt();
      this.setShowUpdatesButtonVisibility();
    },

    refreshNewStoriesCount: function() {
      this.model.set('newStoriesCount', this.collection.where({isNew: true}).length);
    },

    checkScroll: function(view) {
      return function () {
        var triggerPoint = 100;
        if( !view.isLoading && this.scrollTop + this.clientHeight + triggerPoint > this.scrollHeight ) {
          view.collection.fetchPreviousPage();
        }
      }
    },

    setShowUpdatesButtonVisibility: function() {
      if(this.model.get('newStoriesCount') > 0) {
        this.$el.find('.js-show-new-stories').removeClass('hidden');
      } else {
        this.$el.find('.js-show-new-stories').addClass('hidden');
      }
    },

    refreshTimeRangeVisibility: function(){
      var val = this.model.get('sort_column');
      if(val == "shares_count") {
        this.$el.find('.stream-settings .time-range').show();
        this.$el.find('.stream-settings').addClass('expand');
      } else if(val == "published_at") {
        this.$el.find('.stream-settings .time-range').hide();
        this.$el.find('.stream-settings').removeClass('expand');
      }
    }
  });

});
