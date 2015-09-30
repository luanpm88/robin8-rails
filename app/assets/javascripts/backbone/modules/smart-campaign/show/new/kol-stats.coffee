Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.KolStatsView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/kol-stats'

    serializeData: () ->
      k: @model.toJSON()

    onRender: () ->
      self = this
      self.initHighcharts(self)

    initialize: (opts) ->
      @model = new Robin.Models.KolProfile @options.kol
      @initial_attrs = @model.toJSON()

    initHighcharts: (self) ->
      normalize = (max, v) ->
        if v == 0
          return 10  # avoid zero values so graph looks nicer for losers
        (v / max) * 100

      d = [
        [
          {axis:"Your influence channel",value:100},
          {axis:"Social engagement",value:100},
          {axis:"Content generation",value:100},
          {axis:"Weibo fans",value:100},
          {axis:"Validity of social profile",value:100},
        ],
        [
          {axis:"Your influence channel",value:normalize(30, @model.attributes.stats.channels)},
          {axis:"Social engagement",value: normalize(10, @model.attributes.stats.engagement)},
          {axis:"Content generation",value: normalize(10, @model.attributes.stats.content)},
          {axis:"Weibo fans",value: normalize(10, @model.attributes.stats.fans)},
          {axis:"Validity of social profile",value: normalize(40, @model.attributes.stats.completeness)}
        ]
      ]
      mycfg = {
        w: 180,
        h: 150,
        maxValue: 100,
        levels: 0,
        ExtraWidthX: 150
      }


      el = self.$('#graph_score2')

      RadarChart.draw(el[0], d, mycfg)
