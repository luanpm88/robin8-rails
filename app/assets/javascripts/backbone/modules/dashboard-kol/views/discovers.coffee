Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.DiscoverItem = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/discover-item'
    tagName: 'li'
    className: 'discover-item'


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
