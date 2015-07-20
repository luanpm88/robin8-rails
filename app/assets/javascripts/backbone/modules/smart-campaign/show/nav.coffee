Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->
  Show.Nav = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/nav'
    tagName: 'ul'
    className: 'breadcrumb'

    serializeData: () ->
      active: @options.active or "start",
      pages: ["start", "target", "pitch"]
