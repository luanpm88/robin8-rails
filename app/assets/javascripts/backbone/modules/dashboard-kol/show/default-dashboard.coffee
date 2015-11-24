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

    initialize: ()->
      if !@model.get('user_id')
        @isFail = true
      else
        @isFail = false

    serializeData: () ->
      isFail: @isFail


  # Show.Discovers = Backbone.Marionette.CompositeView.extend
  #   template: ''
  #
  #   childView: DiscoverItem
  #
  # Show.DiscoverItem = Backbone.Marionette.ItemView.extend
  #   template: ''
