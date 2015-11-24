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

    onRender: () ->
      @initInfluenceItem()

    initInfluenceItem: () ->
      item = new Robin.Models.SocialInfluence
      @view = new Show.InfluenceItem
        model: item
      fetchingItem = item.fetch()
      parentThis = @
      $.when(fetchingItem).done(->
        console.log item
        parentThis.getRegion('item').show parentThis.view
      )

  Show.InfluenceItem = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/influence-item'
    tagName: 'div'


  # Show.Discovers = Backbone.Marionette.CompositeView.extend
  #   template: ''
  #
  #   childView: DiscoverItem
  #
  # Show.DiscoverItem = Backbone.Marionette.ItemView.extend
  #   template: ''
