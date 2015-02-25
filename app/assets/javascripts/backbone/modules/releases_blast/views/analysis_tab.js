Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.AnalysisTabView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/analysis-tab',
    className: 'row',
    model: Robin.Models.Release,
    events: {
      'click #btn-next': 'openTargetsTab'
    },
    initialize: function(){
      this.on("textapi_result:ready", this.render);
      this.getTextApiResult();
      this.textapiResult = {};
    },
    templateHelpers: function(){
      return {
        textapiResult: this.textapiResult
      }
    },
    onRender: function () {
      // Get rid of that pesky wrapping-div.
      // Assumes 1 child element present in template.
      this.$el = this.$el.children();
      // Unwrap the element to prevent infinitely 
      // nesting elements during re-render.
      this.$el.unwrap();
      this.setElement(this.$el);
      this.$el.find('#release-category').editable();

      this.$el.find('#release-topics').editable({
        source: _.map(this.textapiResult["concepts"], function(item){
          return {
            id: item.topic.replace(/ /g, '_'),
            text: item.topic
          }
        }),
        select2: {
          multiple: true
        }
      });
    },
    openTargetsTab: function(){
      ReleasesBlast.controller.targets();
    },
    getTextApiResult: function(){
      var that = this;
      var endpoints = [
        'textapi/classify', 
        'textapi/concepts', 
        'textapi/summarize'
      ];
      
      var resultReady = _.after(endpoints.length + 1, function(){
        that.trigger("textapi_result:ready");
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
            title: that.model.attributes.title, 
            text: that.model.attributes.text
          },
          success: function(response){
            switch(endpoint) {
              case 'textapi/concepts':
                var prBody = that.model.attributes.text;
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
                
                boldTopicsInSummary();
                resultReady();
                break;
              case 'textapi/classify':
                that.textapiResult["classify"] = _(response[0].label.split(" - ")).map(function(p) {
                    return p.charAt(0).toUpperCase() + p.slice(1);
                  }).join(' - ');
                resultReady();
                break;
              case 'textapi/summarize':
                that.textapiResult["summarize"] = response;
                boldTopicsInSummary();
                resultReady();
                break;
            }
          }
        });
      });
    }
  });
});
