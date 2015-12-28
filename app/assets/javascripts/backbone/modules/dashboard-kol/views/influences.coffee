Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.PersonalInfo = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/personal-info'

    serializeData: () ->
      score_data: @options.score_data

  Show.Influence = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/influence'

    regions:
      item: '.influence-item'

    events:
      'click .dropdown-menu li a': 'switchAccount'

    onRender: () ->
      Show.CustomController.showInfluenceItem(null, @collection, @getRegion('item'))
      console.log @options.score_data

    serializeData: () ->
      items: @collection.toJSON();

    switchAccount: (e) ->
      _gaq.push(['_trackPageview', '/some-page'])
      e.preventDefault()
      identity_id = e.target.id
      influence = new Robin.Models.SocialInfluence({id: identity_id})
      Show.CustomController.showInfluenceItem(influence, @collection, @getRegion('item'))


  Show.InfluenceItem = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/influence-item'
    tagName: 'div'

    onRender: ()->
      parentThis = @
      _.defer ->
        myChartLeft = echarts.init(document.getElementById('influence-charts-left'))
        myChartRight = echarts.init(document.getElementById('influence-charts-right'))
        legend_data = []
        conf_data = []
        indicator_data = []
        cloud_data = []
        for label in parentThis.model.get('labels')
          legend_data.push polyglot.t 'dashboard_kol.influence_charts.' + label.name
          t={}
          t.text = polyglot.t 'dashboard_kol.influence_charts.' + label.name
          t.value = 100
          indicator_data.push t
          conf_data.push label.conf*100

        for keyword in parentThis.model.get('keywords')
          t={}
          t.name = keyword
          t.value = Math.random() * 100
          t.itemStyle = createRandomItemStyle()
          cloud_data.push t

        optionRight =
          series:[
            {
              type: 'wordCloud'
              size: ['80%', '80%']
              textRotation: [0,0]
              textPadding: 0
              autoSize: {
                enable: true
                minSize: 14
              }
              data: cloud_data
            }
          ]

        optionLeft =
          legend:
            show: false
            x: 'center'
            data: legend_data
          calculable: true
          polar: [ {
            indicator: indicator_data
            radius: 100
          }]
          series: [
            type: 'radar'
            data: [
              {
                value: conf_data
              }
            ]
          ]

        myChartLeft.setOption optionLeft
        myChartRight.setOption optionRight

    serializeData: () ->
      item: @model.toJSON()

    createRandomItemStyle = ->
      { normal: color: 'rgb(' + [
        Math.round(Math.random() * 160)
        Math.round(Math.random() * 160)
        Math.round(Math.random() * 160)
      ].join(',') + ')' }
