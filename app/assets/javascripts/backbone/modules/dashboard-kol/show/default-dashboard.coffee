Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.DefaultDashboard = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/default-dashboard'

    regions:
      socialInfluencePower: '#social-influence-power'
      campaign: '#default-dashboard-campaign'
      discover: '#default-dashboard-discover'

    onRender: () ->
      Show.CustomController.showInfluencesAndDiscovers @getRegion('socialInfluencePower'), @getRegion('discover')

  Show.Influence = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/influence'

    regions:
      item: '.influence-item'

    events:
      'click .dropdown-menu li a': 'switchAccount'

    onRender: () ->
      Show.CustomController.showInfluenceItem(null, @collection, @getRegion('item'))
      console.log @options.score_data

    serializeData: () ->
      items: @collection.toJSON();
      score_data: @options.score_data

    switchAccount: (e) ->
      _gaq.push(['_trackPageview', '/some-page'])
      e.preventDefault()
      identity_id = e.target.id
      influence = new Robin.Models.SocialInfluence({id: identity_id})
      Show.CustomController.showInfluenceItem(influence, @collection, @getRegion('item'))
      # todo: reload discover after social account switched.

  Show.InfluenceItem = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/influence-item'
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
      isFail: @isFail
      item: @model.toJSON()

    createRandomItemStyle = ->
      { normal: color: 'rgb(' + [
        Math.round(Math.random() * 160)
        Math.round(Math.random() * 160)
        Math.round(Math.random() * 160)
      ].join(',') + ')' }

  Show.SocialNotExisted = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/social_not_existed'

  Show.DiscoverItem = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/discover_item'
    tagName: 'li'
    className: 'discover-item'

  Show.DiscoversLayout = Backbone.Marionette.CompositeView.extend
    template: 'modules/dashboard-kol/show/templates/discovers_layout'
    childView: Show.DiscoverItem
    childViewContainer: 'ul'

    initialize: (opts) ->
      @parentRegion = opts.parentRegion

    onShow: () ->
      parentThis = @
      $(window).scroll ->
        if $(window).scrollTop() + $(window).height() == $(document).height()
          $('#loadingDiscover').show()
          Show.CustomController.appendMoreDiscovers parentThis.parentRegion
