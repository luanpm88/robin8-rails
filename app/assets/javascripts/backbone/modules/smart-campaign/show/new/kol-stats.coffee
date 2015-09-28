Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.KolStatsView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/kol-stats'

    templateHelpers: () ->
      vs: () ->
        polyglot.t('dashboard_kol.score_tab.vsmonth', {per: "+25%" })
      beat: () ->
        polyglot.t('dashboard_kol.score_tab.youbeat', {per: "50%" })
      score: () ->
        "75"

    onRender: () ->
      self = this
      self.initHighcharts(self)

    initHighcharts: (self) ->
      self.$(".graph-score").knob()

      d = [
        [
          {axis:"Your influence channel",value:50},
          {axis:"Social engagement",value:60},
          {axis:"Content generation",value:42},
          {axis:"Weibo fans",value:34},
          {axis:"Validity of social profile",value:48},
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


