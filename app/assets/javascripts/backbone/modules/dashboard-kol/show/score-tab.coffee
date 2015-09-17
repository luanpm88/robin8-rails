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
      w = 200
      h = 180

      colorscale = d3.scale.category10()
      #Legend titles
      LegendOptions = ['Smartphone','Tablet']
      #Data
      d = [
        [
          {axis:"Email",value:0.59},
          {axis:"Social Networks",value:0.56},
          {axis:"Internet Banking",value:0.42},
          {axis:"News Sportsites",value:0.34},
          {axis:"Search Engine",value:0.48},
          {axis:"View Shopping sites",value:0.14},
          {axis:"Paying Online",value:0.11},
          {axis:"Buy Online",value:0.05},
          {axis:"Stream Music",value:0.07},
          {axis:"Online Gaming",value:0.12},
          {axis:"Navigation",value:0.27},
          {axis:"App connected to TV program",value:0.03},
          {axis:"Offline Gaming",value:0.12},
          {axis:"Photo Video",value:0.4},
          {axis:"Reading",value:0.03},
          {axis:"Listen Music",value:0.22},
          {axis:"Watch TV",value:0.03},
          {axis:"TV Movies Streaming",value:0.03},
          {axis:"Listen Radio",value:0.07},
          {axis:"Sending Money",value:0.18},
          {axis:"Other",value:0.07},
          {axis:"Use less Once week",value:0.08}
        ], [
          
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

