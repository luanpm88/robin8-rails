Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.DefaultDashboard = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/default-dashboard'

    regions:
      socialInfluencePower: '#social-influence-power'
      campaign: '#default-dashboard-campaign'
      discover: '#default-dashboard-discover'

    onRender: () ->
      console.log 'on render'
      @initInfluence()

    initInfluence: () ->
      socialList = new Robin.Collections.Identities
      @influence_view = new Show.Influence
        collection: socialList
      socialList.fetch
        success: (collection, res, opts) =>
          @getRegion('socialInfluencePower').show @influence_view

  Show.Influence = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/influence'

    regions:
      item: '.influence-item'

    events:
      'click .dropdown-menu li a': 'switchAccount'

    onRender: () ->
      @initInfluenceItem()

    serializeData: () ->
      items: @collection.toJSON();

    initInfluenceItem: (influence) ->
      item = influence || new Robin.Models.SocialInfluence({id: @collection.models[0].get('id')})
      @view = new Show.InfluenceItem
        model: item
      fetchingItem = item.fetch()
      parentThis = @
      $.when(fetchingItem).done(->
        parentThis.getRegion('item').show parentThis.view
      ).fail(->
        parentThis.getRegion('item').show parentThis.view
      )

    switchAccount: (e) ->
      e.preventDefault()
      identity_id = e.target.id
      influence = new Robin.Models.SocialInfluence({id: identity_id})
      fetchingInfluence = influence.fetch();
      parentThis = @
      $.when(fetchingInfluence).done(->
        parentThis.initInfluenceItem(influence)
      ).fail(->
        parentThis.initInfluenceItem(influence)
      )

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
          legend_data.push label.name
          t={}
          t.text = label.name
          t.value = 100
          indicator_data.push t
          conf_data.push label.conf*100

        for keyword in parentThis.model.get('keywords')
          t={}
          t.name = keyword
          t.value = Math.random() * 100
          t.itemStyle = createRandomItemStyle()
          console.log t
          cloud_data.push t

        console.log cloud_data

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

    initialize: ()->
      if !@model.get('user_id')
        @isFail = true
      else
        @isFail = false

    serializeData: () ->
      isFail: @isFail
      item: @model.toJSON()

    createRandomItemStyle = ->
      { normal: color: 'rgb(' + [
        Math.round(Math.random() * 160)
        Math.round(Math.random() * 160)
        Math.round(Math.random() * 160)
      ].join(',') + ')' }

  # Show.Discovers = Backbone.Marionette.CompositeView.extend
  #   template: ''
  #
  #   childView: DiscoverItem
  #
  # Show.DiscoverItem = Backbone.Marionette.ItemView.extend
  #   template: ''
