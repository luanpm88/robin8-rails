Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.DiscoverItem = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/discover-item'
    tagName: 'li'
    className: 'discover-item'

    events:
      'click a': 'trackViewRecord'

    trackViewRecord: (e) ->
      discoverId = $(e.target).data('id')
      kolId = Robin.currentKOL.get('id')
      discoverRecord = new Robin.Models.DiscoverRecord {kol_id: kolId, discover_id: discoverId}
      discoverRecord.save
        success: (model, res, opts) =>
          console.log 'track success'
        error: =>
          console.log 'tract error...'

  Show.DiscoversLayout = Backbone.Marionette.CompositeView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/discovers-layout'
    childView: Show.DiscoverItem
    childViewContainer: 'ul'

    initialize: (opts) ->
      @parentRegion = opts.parentRegion
      @collection.fetch
        success: (collection, res, opts) =>
          if @parentRegion.$el.find('ul').children('li').length == 0
            @.render()
        error: =>
          console.log 'fire Show.DiscoversLayout.initalize: fetch collection error'

    onShow: () ->
      parentThis = @
      $(window).scroll ->
        if $(window).scrollTop() + $(window).height() == $(document).height()
          $('#loadingSvg').show()
          Show.CustomController.appendMoreDiscovers(parentThis.parentRegion)
