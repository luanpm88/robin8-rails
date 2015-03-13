Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.AnalysisTabView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/analysis-tab/analysis-tab',
    model: Robin.Models.Release,
    ui: {
      nextButton: '#btn-next',
      iptcCategoryLink: '#release-category',
      topicsLink: '#release-topics'
    },
    events: {
      'click @ui.nextButton': 'openTargetsTab'
    },
    initialize: function(options){
      this.on("textapi_result:ready", this.render);
      this.getTextApiResult();
      this.textapiResult = {};
    },
    templateHelpers: function(){
      return {
        textapiResult: this.textapiResult
      }
    },
    makeIptcCategoriesEditable: function(){
      var self = this;
      
      this.ui.iptcCategoryLink.editable({
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
      
      var concepts = _.map(this.model.get("concepts"), function(item){
        return {
          id: item.replace(/_/g, ' '),
          text: item.replace(/_/g, ' ')
        }
      });
      
      this.ui.topicsLink.editable({
        inputclass: 'input-large',
        select2: {
          tags: concepts,
          multiple: true,
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
    },
    openTargetsTab: function(){
      this.model.save();
      
      ReleasesBlast.controller.targets();
    },
    getTextApiResult: function(){
      var that = this;
      var endpoints = [
        'textapi/classify', 
        'textapi/concepts', 
        'textapi/summarize',
        'textapi/hashtags'
      ];
      
      var resultReady = _.after(endpoints.length + 1, function(){
        that.trigger("textapi_result:ready");
        that.ui.nextButton.prop('disabled', false);
      });
      
      var boldTopicsInSummary = _.after(2, function() {
        var sfs = _.chain(that.textapiResult["concepts"])
          .map(function(item){return '\\b' + item.sfs + '\\b'; })
          .uniq()
          .value();
          
        var pattern = new RegExp('(' + sfs.join('|') + ')', 'ig');

        that.textapiResult["summarize"] = _(that.textapiResult["summarize"]).inject(function(memo, item) {
          memo.push(item.replace(pattern, function($1, match) { return '<strong>' + $1 + '</strong>'; }));
          return memo;
        }, []);
        resultReady();
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
                    var pattern = new RegExp('\\b' + sf.string + '\\b', 'ig');
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
                that.textapiResult["concepts"] = renderedTopics;
                
                var concepts = _.pluck(that.textapiResult["concepts"], 'uri');
                concepts = _.map(concepts, function(item){
                  return item.replace("http://dbpedia.org/resource/", '');
                });
                that.model.set('concepts', concepts);
                
                boldTopicsInSummary();
                resultReady();
                break;
              case 'textapi/classify':
                that.textapiResult["classify"] = _(response[0].label.split(" - ")).map(function(p) {
                    return p.charAt(0).toUpperCase() + p.slice(1);
                  }).join(' - ');
                
                var iptc_categories = _.chain(response).pluck('code').uniq().value();
                that.model.set('iptc_categories', iptc_categories);
                
                resultReady();
                break;
              case 'textapi/summarize':
                that.textapiResult["summarize"] = _(response).first(5);
                that.model.set('summaries', response);
                boldTopicsInSummary();
                resultReady();
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
