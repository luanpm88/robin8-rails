Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.AnalysisTabView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/analysis-tab/analysis-tab',
    model: Robin.Models.Release,
    ui: {
      nextButton: '#btn-next',
      iptcCategoryLink: '#release-category',
      topicsLink: '#release-topics',
      summariesLines: '#summaries li'
    },
    events: {
      'click @ui.nextButton': 'openTargetsTab'
    },
    initialize: function(options){
      this.model.set('location', null);
      this.on("textapi_result:ready", this.render);
      this.getTextApiResult();
      this.textapiResult = {};
      
      var self = this;
      Robin.commands.setHandler("goToTargetsTab", function(){
        if (self.ui.nextButton.prop('disabled') === false){
          self.openTargetsTab();
        }
      });
      
      this.on("close", function(){ 
        Robin.commands.removeHandler("goToTargetsTab");
      });
    },
    templateHelpers: function(){
      return {
        textapiResult: this.textapiResult
      }
    },
    initSummariesEditable: function(){
      var self = this;
      
      this.ui.summariesLines.editable({
        mode: 'popup',
        type: 'textarea',
        unsavedclass: null,
        display: function(value, response) {
          var html = $.fn.editableutils.escape(self.boldTopicsInSummaryLine(value));
          var pattern = new RegExp("&lt;strong&gt;(.*?)&lt;\/strong&gt;", 'ig');
          
          html = html.replace(pattern, "<strong>$1</strong>");
          
          if(html.length > 0) {
            $(this).html(html);
          } else {
            $(this).empty(); 
          }
        },
        success: function(response, newValue) {
          var sentence_number = parseInt($(this).attr('pk'));
          var summaries = self.model.get('summaries');
          summaries[sentence_number] = newValue;
          
          self.model.set('summaries', summaries);
          
          return {newValue: newValue};
        }
      });
    },
    makeIptcCategoriesEditable: function(){
      var self = this;
      
      this.ui.iptcCategoryLink.editable({
        mode: 'popup',
        name: 'iptc_categories',
        select2: {
          placeholder: 'Select a category',
          allowClear: true,
          ajax: {
            url: '/autocompletes/iptc_categories',
            dataType: 'json',
            data: function (term, page) {
              return { term: term };
            },
            results: function (data, page) {
              return { results: data };
            }
          }
        },
        success: function(response, newValue) {
          self.model.set('iptc_categories', [newValue]);
        }
      });
    },
    makeTopicsEditable: function(){
      var self = this;
      
      this.ui.topicsLink.editable({
        mode: 'popup',
        inputclass: 'input-large',
        select2: {
          tags: true,
          ajax: {
            url: '/autocompletes/topics',
            dataType: 'json',
            data: function (term, page) {
              return { term: term };
            },
            results: function (data, page) {
              var concepts = _.map(data, function(item){
                return {
                  id: item.text,
                  text: item.text
                }
              });
              return { results: concepts };
            }
          },
          initSelection: function(element, callback) {
            var concepts = _.map(self.model.get("concepts"), function(item){
              return {
                id: item.replace(/_/g, ' '),
                text: item.replace(/_/g, ' ')
              }
            });
      
            callback(concepts);
          },
          multiple: true,
          minimumInputLength: 1,
          placeholder: 'Select a topic',
          createSearchChoice: function () { return null }
        },
        success: function(response, newValue) {
          self.model.set('concepts', _(newValue).map(function(item){ 
            return item.replace(/ /g, '_')
          }));
        }
      });
    },
    onRender: function () {
      this.makeIptcCategoriesEditable();
      this.makeTopicsEditable();
      this.initSummariesEditable();
    },
    openTargetsTab: function(){
      this.model.save();
      
      ReleasesBlast.controller.targets();
    },
    boldTopicsInSummaryLine: function(summary){
      var sfs = [];
      
      if (_.isString(this.textapiResult["concepts"])){
        sfs = _.chain(this.textapiResult["concepts"].split(','))
          .map(function(item){ return '\\b' + RegExp.escape(item.trim()) + '\\b'; })
          .uniq()
          .value();
      } else {
        var sfs = _.chain(this.textapiResult["concepts"])
          .map(function(item){return '\\b' + RegExp.escape(item.sfs) + '\\b'; })
          .uniq()
          .value();
      }
      
      var pattern = new RegExp('(' + sfs.join('|') + ')', 'ig');

      summary = summary.replace(pattern, function($1, match) { 
        return '<strong>' + $1 + '</strong>'; 
      });
      
      return summary;
    },
    getTextApiResult: function(){
      var that = this;
      var endpoints = [
        'textapi/classify', 
        'textapi/concepts', 
        'textapi/summarize',
        'textapi/hashtags'
      ];
      
      var resultReady = _.after(endpoints.length, function(){
        that.trigger("textapi_result:ready");
        that.ui.nextButton.prop('disabled', false);
      });
      
      _.each(endpoints, function(endpoint){
        $.ajax({
          url: endpoint,
          dataType: 'json',
          method: 'POST',
          data: {
            title: that.model.get('title'), 
            text: that.model.get('plain_text'),
            sentences_number: 10
          },
          success: function(response){
            switch(endpoint) {
              case 'textapi/concepts':
                var prBody = that.model.get('plain_text');
                var countedTopics = _.chain(response).foldl(function(memo, t, z) {
                  _(t.surfaceForms).each(function(sf) {
                    var pattern = new RegExp('\\b' + RegExp.escape(sf.string) + '\\b', 'ig');
                    var count = (prBody.match(pattern) || []).length;
                    if (z in memo) { memo[z] += count; } else { memo[z] = count; }
                  });
                  return memo;
                }, {}).value();
                var renderedTopics = _.chain(response).map(function(data, label) {
                  var types = _.chain(data.types).filter(function(t) {
                    return t.startsWith("http://schema.org/");
                  }).map(function(t) { return t.replace('http://schema.org/', ''); }).value();
                  data.types = types;
                  return {"label": label, "data": data };
                }).partition(function(topic) {
                  return _.intersection(["Place","Organization","Person"], topic.data.types).length > 0;
                }).map(function(a) {
                  return _(a).sortBy(function(topic) { return -countedTopics[topic.label]; });
                }).reduce(function(a,b) {
                  return a.concat(b);
                }, []).map(function(topic) {
                  var sfs = _(topic.data.surfaceForms).map(function(sf) { return sf.string; }).join('|');
                  var topic_title = topic.label.replace('http://dbpedia.org/resource/', '').replace(/_/g, ' ');
                  return {
                    topic: topic_title,
                    uri: topic.label,
                    sfs: sfs,
                    freq: countedTopics[topic.label]
                  };
                }).value();
                
                if (s.isBlank(that.model.get('concepts'))){
                  that.textapiResult["concepts"] = _.pluck(renderedTopics, 'topic')
                    .join(', ');
                
                  var concepts = _.pluck(that.textapiResult["concepts"], 'uri');
                  concepts = _.map(concepts, function(item){
                    return item.replace("http://dbpedia.org/resource/", '');
                  });
                  that.model.set('concepts', concepts);
                  
                  resultReady();
                } else {
                  that.textapiResult["concepts"] = _.map(that.model.get('concepts'), function(item){
                    return item.replace(/_/g, ' ');
                  }).join(', ');
                  
                  resultReady();
                }
                
                break;
              case 'textapi/classify':
                /* Temporary code */
                var label = response[0].label;
                var re = /unrest, conflicts and war.*/;
                if (re.exec(label))
                  label = "society - issue";
                
                if (label === "religion and belief - cult and sect")
                  label = "arts, culture and entertainment - culture";
                /* END of Temporary code */
                
                if (s.isBlank(that.model.get('iptc_categories'))){
                  that.textapiResult["classify"] = _(label.split(" - ")).map(function(p) {
                    return p.charAt(0).toUpperCase() + p.slice(1);
                  }).join(' - ');
                  
                  var iptc_categories = _.chain(response).pluck('code')
                    .uniq().value();
                  that.model.set('iptc_categories', iptc_categories);
                  
                  resultReady();
                } else {
                  $.ajax({
                    dataType: 'json',
                    method: 'GET',
                    url: '/iptc_categories/' + that.model.get('iptc_categories')[0],
                    success: function(response){
                      that.textapiResult["classify"] = response.label;
                      
                      resultReady();
                    }
                  });
                }
                
                break;
              case 'textapi/summarize':
                if (s.isBlank(that.model.get('summaries'))) {
                  that.textapiResult["summarize"] = _(response).first(5);
                  that.model.set('summaries', response);
                  
                  resultReady();
                } else {
                  that.textapiResult["summarize"] = _(that.model.get('summaries'))
                    .first(5);
                  
                  resultReady();
                }
                
                break;
              case 'textapi/hashtags':
                that.textapiResult["hashtags"] = _.uniq(response);
                that.model.set('hashtags', that.textapiResult["hashtags"]);
                resultReady();
                break;
            }
          }
        });
      });
    }
  });
});
