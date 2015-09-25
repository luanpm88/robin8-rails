Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.ScoreTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/score-tab'
    ui:
      form: '#score_form'


    onRender: () ->
      self = this
      @ui.form.ready(self.init(self))

    init: (self) ->
      self.$(".graph-score").knob()


      w = 500
      h = 500

      colorscale = d3.scale.category10()

      #Data
      d = [
        [
          {axis:"Your influence channel",value:0.59},
          {axis:"Validity of social profile",value:0.56},
          {axis:"Weibo fans",value:0.42},
          {axis:"Content generation",value:0.34},
          {axis:"Social engagement",value:0.48},
        ]
      ]

      #Options for the Radar chart, other than default
      mycfg = {
        w: w,
        h: h,
        maxValue: 0.6,
        levels: 6,
        ExtraWidthX: 300
      }

      #Call function to draw the Radar chart
      #Will expect that data is in %'s
      RadarChart.draw("#graph-score2", d, mycfg)



