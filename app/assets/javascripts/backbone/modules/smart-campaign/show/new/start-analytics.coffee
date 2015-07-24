Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.StartAnalytics = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/start-tab-analysis'

    ui:
      nextButton: '#btn-next'
      iptcCategoryLink: '#release-category'
      topicsLink: '#release-topics'
      summariesLines: '#summaries li'
      reanalyzeButton: 'sup i'

    events:
      'click @ui.reanalyzeButton': 'reanalyzeButtonClicked'
      'click @ui.nextButton': 'openTargetTab'

    initialize: (options) ->
      @on("textapi_result:ready", @render)
      @getTextApiResult()
      @textapiResult = {}
      @title = document.getElementById("name").value.replace(/<(?:.|\n)*?>/gm, '')
      @model = if @options.model? then @options.model else new Robin.Models.Campaign()
      @reanalyze = @options.reanalyze

    templateHelpers: () ->
        textapiResult: @textapiResult
        title: @title
        isresultReady: @isresultReady

    initTooltip: () ->
      @ui.reanalyzeButton.tooltip()

    reanalyzeButtonClicked: () ->
      child = new Show.StartAnalytics ({
        model: @model
        reanalyze: true
      })
      Robin.layouts.main.content.currentView.content.currentView.analyticsRegion.show child

    openTargetTab: () ->
      @options.parent.setState('target')

    initSummariesEditable: () ->
      self = this

      @ui.summariesLines.editable {
        mode: 'popup'
        type: 'textarea'
        unsavedclass: null
        display: (value, response) ->
          html = $.fn.editableutils.escape(self.boldTopicsInSummaryLine(value))
          pattern = new RegExp("&lt;strong&gt;(.*?)&lt;\/strong&gt;", 'ig')

          html = html.replace(pattern, "<strong>$1</strong>")

          if html.length > 0
            $(this).html(html)
          else
            $(this).empty()

        success: (response, newValue) ->
          sentence_number = parseInt($(this).attr('pk'))
          summaries = self.model.get('summaries')
          summaries[sentence_number] = newValue

          self.model.set('summaries', summaries)

          return {newValue: newValue}
      }
    boldTopicsInSummaryLine: (summary) ->
      sfs = []

      if _.isString(this.textapiResult["concepts"])
        sfs = _.chain(this.textapiResult["concepts"].split(','))
          .map((item) -> return '\\b' + RegExp.escape(item.trim()) + '\\b' )
          .uniq()
          .value()
      else
        sfs = _.chain(this.textapiResult["concepts"])
          .map((item) -> return '\\b' + RegExp.escape(item.sfs) + '\\b' )
          .uniq()
          .value()

      pattern = new RegExp('(' + sfs.join('|') + ')', 'ig')

      summary = summary.replace(pattern, ($1, match) ->
        return '<strong>' + $1 + '</strong>'
      )
      return summary

    makeIptcCategoriesEditable: () ->
      self = this

      @ui.iptcCategoryLink.editable(
        name: 'iptc_categories'
        select2: {
          placeholder: 'Select a category'
          allowClear: true
          ajax: {
            url: '/autocompletes/iptc_categories'
            dataType: 'json'
            data: (term, page) ->
              return { term: term }
            results:  (data, page) ->
              return { results: data }
          }
        },
        success: (response, newValue) ->
          self.model.set('iptc_categories', [newValue])
      )

    makeTopicsEditable: () ->
      self = this

      @ui.topicsLink.editable(
        inputclass: 'input-large'
        select2: {
          tags: true
          ajax: {
            url: '/autocompletes/topics'
            dataType: 'json'
            data: (term, page) ->
              return { term: term }
            results: (data, page) ->
              concepts = _.map(data, (item) ->
                return {
                  id: item.text
                  text: item.text
                }
              )
              return { results: concepts }
          }
          initSelection: (element, callback) ->
            concepts = _.map(self.model.get("concepts"), (item) ->
              return {
                id: item.replace(/_/g, ' ')
                text: item.replace(/_/g, ' ')
              }
            )

            callback(concepts)
          multiple: true
          minimumInputLength: 1
          placeholder: 'Select a topic'
          createSearchChoice: () ->  return null
        }
        success: (response, newValue) ->
          self.model.set('concepts', _(newValue).map((item) ->
            return item.replace(/ /g, '_')
          ))
      )

    onRender: () ->
      @makeIptcCategoriesEditable()
      @makeTopicsEditable()
      @initSummariesEditable()
      @initTooltip()

    transformLabel: (label, code) ->
      if code.substring(0, 2) == "16"
        label = "Society - Issue"

      if code == "12001000"
        label = "Arts, Culture and Entertainment - Culture"

      return label

    getTextApiResult: () ->
      editor = document.getElementById("release-form")
      editor = editor.value.replace(/<(?:.|\n)*?>/gm, '')
      title = document.getElementById("name")
      title = title.value.replace(/<(?:.|\n)*?>/gm, '')
      that = this
      endpoints = [
        'textapi/classify',
        'textapi/concepts',
        'textapi/summarize',
        'textapi/hashtags'
      ]

      resultReady = _.after(endpoints.length, () ->
        that.trigger("textapi_result:ready")
      )

      _.each(endpoints, (endpoint) ->
        $.ajax({
          url: endpoint
          dataType: 'json'
          method: 'POST'
          data: {
            title: title
            text: editor
            sentences_number: 10
          },
          success: (response) ->
            switch endpoint
              when 'textapi/concepts'
                prBody = editor
                countedTopics = _.chain(response).foldl((memo, t, z) ->
                  _(t.surfaceForms).each((sf) ->
                    pattern = new RegExp('\\b' + RegExp.escape(sf.string) + '\\b', 'ig')
                    count = (prBody.match(pattern) || []).length
                    if z in memo
                      memo[z] += count
                    else
                      memo[z] = count
                  )
                  return memo
                , {}).value()
                renderedTopics = _.chain(response).map((data, label) ->
                  types = _.chain(data.types).filter((t) ->
                    return t.startsWith("http://schema.org/")
                  ).map((t)-> return t.replace('http://schema.org/', '') ).value()
                  data.types = types
                  return {"label": label, "data": data }
                ).partition((topic) ->
                  return _.intersection(["Place","Organization","Person"], topic.data.types).length > 0
                ).map((a) ->
                  return _(a).sortBy((topic) -> return -countedTopics[topic.label] )
                ).reduce((a,b) ->
                  return a.concat(b)
                , []).map((topic) ->
                  sfs = _(topic.data.surfaceForms).map((sf)->  return sf.string ).join('|')
                  topic_title = topic.label.replace('http://dbpedia.org/resource/', '').replace(/_/g, ' ')
                  return {
                    topic: topic_title,
                    uri: topic.label,
                    sfs: sfs,
                    freq: countedTopics[topic.label]
                  }
                ).value()

                if that.reanalyze || s.isBlank(that.model.get('concepts'))
                  concepts = _.pluck(renderedTopics, 'uri')
                  concepts = _.map(concepts, (item) ->
                    return item.replace("http://dbpedia.org/resource/", '')
                  )
                  that.model.set('concepts', concepts)

                  that.textapiResult["concepts"] = _.pluck(renderedTopics, 'topic')
                    .join(', ')

                  resultReady()
                else
                  that.textapiResult["concepts"] = _.map(that.model.get('concepts'), (item) ->
                    return item.replace(/_/g, ' ')
                  ).join(', ')

                  resultReady()
              when 'textapi/classify'
                if that.reanalyze || s.isBlank(that.model.get('iptc_categories'))
                  that.textapiResult["classify"] = _(that.transformLabel(response[0].label,
                    response[0].code).split(" - ")).map((p) ->
                    return p.charAt(0).toUpperCase() + p.slice(1)
                    ).join(' - ')

                  iptc_categories = _.chain(response).pluck('code')
                    .uniq().value()
                  that.model.set('iptc_categories', iptc_categories)

                  resultReady()
                else
                  $.ajax({
                    dataType: 'json',
                    method: 'GET',
                    url: '/iptc_categories/' + that.model.get('iptc_categories')[0],
                    success: (response)->
                      that.textapiResult["classify"] = that.transformLabel(response.label,
                        response.id)

                      resultReady()
                  })
              when 'textapi/summarize'
                if that.reanalyze || s.isBlank(that.model.get('summaries'))
                  that.textapiResult["summarize"] = _(response).first(5)
                  that.model.set('summaries', response)

                  resultReady()
                else
                  that.textapiResult["summarize"] = _(that.model.get('summaries'))
                    .first(5)

                  resultReady()

              when 'textapi/hashtags'
                that.textapiResult["hashtags"] = _.uniq(response)
                that.model.set('hashtags', that.textapiResult["hashtags"])
                resultReady()
        })
      )
