Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.KolStatsView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/kol-stats'

    serializeData: () ->
      k: @model.toJSON()

    onRender: () ->
      @initHighcharts()
      if @model.attributes.avatar_url
        @$el.find("#avatar-image").attr('src', @model.attributes.avatar_url)

    initialize: (opts) ->
      @model = new Robin.Models.KolProfile @options.kol

    initHighcharts: () ->
      normalize = (max, v) ->
        if v == 0
          return 10  # avoid zero values so graph looks nicer for losers
        (v / max) * 100
      d = [
        [
          {axis: "Influence channels", value: 100},
          {axis: "Social engagement", value: 100},
          {axis: "Content generation", value: 100},
          {axis: "Weibo fans", value: 100},
          {axis: "Validity of social profile", value: 100},
        ],
        [
          {axis: "Influence channels", value: normalize(30, @model.attributes.stats.channels)},
          {axis: "Social engagement", value: normalize(10, @model.attributes.stats.engagement)},
          {axis: "Content generation", value: normalize(10, @model.attributes.stats.content)},
          {axis: "Weibo fans", value: normalize(10, @model.attributes.stats.fans)},
          {axis: "Validity of social profile", value: normalize(40, @model.attributes.stats.completeness)}
        ]
      ]
      mycfg = {
        w: 130,
        h: 120,
        maxValue: 100,
        levels: 0,
        ExtraWidthX: 220
      }
      el = @$el.find('#graph_score2')
      RadarChart.draw(el[0], d, mycfg)
