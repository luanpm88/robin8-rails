Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.AnalysisTabView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/analysis-tab/analysis-tab',
    model: Robin.Models.Release,
    ui: {
      nextButton: '#btn-next',
      iptcCategoryLink: '#release-category',
      topicsLink: '#release-topics',
      summariesLines: '#summaries li',
      reanalyzeButton: 'sup i'
    },
    events: {
      'click @ui.nextButton': 'openTargetsTab',
      'click @ui.reanalyzeButton': 'reanalyzeButtonClicked'
    },
    initialize: function(options){
      this.model.set('location', null);
      this.model.set('author_type_id', null);
      this.on("textapi_result:ready", this.render);
      this.getTextApiResult();
      this.textapiResult = {};
      this.reanalyze = this.options.reanalyze;
      
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
    initTooltip: function(){
      this.ui.reanalyzeButton.tooltip();
    },
    reanalyzeButtonClicked: function(){
      ReleasesBlast.controller.analysis({
        releaseModel: this.model,
        reanalyze: true
      });
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
    makeBosonCategoriesEditable: function(){
      var data = [
        { id: "0", text: "体育"},
        { id: "1", text: "教育"},
        { id: "2", text: "财经"},
        { id: "3", text: "社会"},
        { id: "4", text: "娱乐"},
        { id: "5", text: "军事"},
        { id: "6", text: "国内"},
        { id: "7", text: "科技"},
        { id: "8", text: "互联网"},
        { id: "9", text: "房产"},
        { id: "10", text: "国际"},
        { id: "11", text: "女人"},
        { id: "12", text: "汽车"},
        { id: "13", text: "游戏"}
      ];
      
      var self = this;
      
      this.ui.iptcCategoryLink.editable({
        name: 'boson_categories',
        source: data,
        select2: {
          placeholder: 'Select a category',
          allowClear: true,
          createSearchChoice: function () { return null },
          initSelection: function (element, callback) {
            var found_element = _.findWhere(data, { text: element.val()});
            callback(found_element);
          } 
        },
        success: function(response, newValue) {
          self.model.set('boson_categories', [newValue]);
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
      if (Robin.currentUser.get('locale') == 'zh')
        this.makeBosonCategoriesEditable();
      else
        this.makeIptcCategoriesEditable();
        
      this.makeTopicsEditable();
      this.initSummariesEditable();
      this.initTooltip();
    },
    openTargetsTab: function(){
      this.model.save();
      
      ReleasesBlast.controller.targets();
    },
    transformLabel: function(label, code){
      /* Temporary code */
      if (code.substring(0, 2) == "16")
        label = "Society - Issue";
      
      if (code === "12001000")
        label = "Arts, Culture and Entertainment - Culture";
      
      return label;
      /* END of Temporary code */
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
        var params = {
          title: that.model.get('title'), 
          text: that.model.get('plain_text'),
          sentences_number: 10,
        };
        
        if (endpoint == 'textapi/classify' && Robin.currentUser.get('locale') == 'zh'){
          params.type = "weibo";
        }
    
        $.ajax({
          url: endpoint,
          dataType: 'json',
          method: 'POST',
          data: params,
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
                
                if (that.reanalyze || s.isBlank(that.model.get('concepts'))){
                  var concepts = _.pluck(renderedTopics, 'uri');
                  concepts = _.map(concepts, function(item){
                    return item.replace("http://dbpedia.org/resource/", '');
                  });
                  that.model.set('concepts', concepts);
                  
                  that.textapiResult["concepts"] = _.pluck(renderedTopics, 'topic')
                    .join(', ');
                    
                  resultReady();
                } else {
                  that.textapiResult["concepts"] = _.map(that.model.get('concepts'), function(item){
                    return item.replace(/_/g, ' ');
                  }).join(', ');
                  
                  resultReady();
                }
                
                break;
              case 'textapi/classify':
                if (that.reanalyze || s.isBlank(that.model.get('iptc_categories'))){
                  that.textapiResult["classify"] = _(that.transformLabel(response[0].label, 
                    response[0].code)
                    .split(" - ")).map(function(p) {
                    return p.charAt(0).toUpperCase() + p.slice(1);
                  }).join(' - ');
                  
                var categories = _.chain(response).pluck('code').uniq().value();
                if (Robin.currentUser.get('locale') == 'zh') {
                  that.model.set('boson_categories', categories);
                } else {
                  that.model.set('iptc_categories', categories);
                }
                  
                  resultReady();
                } else {
                  $.ajax({
                    dataType: 'json',
                    method: 'GET',
                    url: '/iptc_categories/' + that.model.get('iptc_categories')[0],
                    success: function(response){
                      that.textapiResult["classify"] = that.transformLabel(response.label,
                        response.id);
                      
                      resultReady();
                    }
                  });
                }
                
                break;
              case 'textapi/summarize':
                if (that.reanalyze || s.isBlank(that.model.get('summaries'))) {
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
