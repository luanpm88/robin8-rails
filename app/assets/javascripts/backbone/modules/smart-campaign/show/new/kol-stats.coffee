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
      self.$(".graph-score").knob()
      d = [
        [
          {axis:"Your influence channel",value:40},
          {axis:"Social engagement",value:40},
          {axis:"Content generation",value:40},
          {axis:"Weibo fans",value:40},
          {axis:"Validity of social profile",value:40},
        ],
        [
          {axis:"Your influence channel",value:@model.attributes.stats.channels},
          {axis:"Social engagement",value:@model.attributes.stats.engagement},
          {axis:"Content generation",value:@model.attributes.stats.content},
          {axis:"Weibo fans",value:@model.attributes.stats.fans},
          {axis:"Validity of social profile",value:@model.attributes.stats.completeness}
        ]
      ]
      mycfg = {
        w: 200,
        h: 150,
        maxValue: 100,
        levels: 1,
        ExtraWidthX: 150
      }


      el = self.$('#graph_score2')

      RadarChart.draw(el[0], d, mycfg)


