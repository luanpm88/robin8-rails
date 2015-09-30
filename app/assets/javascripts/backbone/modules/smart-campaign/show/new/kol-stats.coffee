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
      self.initGauge(self, @model.attributes.stats.total)
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

    initGauge: (self, value) ->
      percent = (value / 100) * 40
      barWidth = 10
      numSections = 40
      sectionPerc = 1 / numSections / 1.5
      padRad = 0.05
      chartInset = 10
      totalPercent = .67

      el = d3.select(self.$('.chart-gauge')[0])

      margin = { top: 20, right: 20, bottom: 20, left: 20 }
      width = 160 - margin.left - margin.right
      height = width
      radius = Math.min(width, height) / 1.6

      percToDeg = (perc) ->
        perc * 360

      percToRad = (perc) ->
        degToRad percToDeg perc

      degToRad = (deg) ->
        deg * Math.PI / 180

      svg = el.append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom)

      chart = svg.append('g')
      .attr('transform', "translate(#{(width + margin.left) / 1.6}, #{(height + margin.top) / 1.6})")

      # build gauge bg
      for sectionIndx in [1..numSections]

        arcStartRad = percToRad totalPercent
        arcEndRad = arcStartRad + percToRad sectionPerc
        totalPercent += sectionPerc

        startPadRad = if sectionIndx is 0 then 0 else padRad / 2
        endPadRad = if sectionIndx is numSections then 0 else padRad / 2

        arc = d3.svg.arc()
        .outerRadius(radius - chartInset)
        .innerRadius(radius - chartInset - barWidth)
        .startAngle(arcStartRad + startPadRad)
        .endAngle(arcEndRad - endPadRad)
        if sectionIndx <= percent
          chart.append('path')
          .attr('class', "arc chart-color1")
          .attr('d', arc)
        else
          chart.append('path')
          .attr('class', "arc chart-color2")
          .attr('d', arc)

      chart.append('circle')
      .attr('class', 'chart-center')
      .attr('cx', 0)
      .attr('cy', 0)
      .attr('r', 50)

      chart.append('text')
      .attr('x', -23)
      .attr('y', 13)
      .attr('class', 'chart-text')
      .text(value)

