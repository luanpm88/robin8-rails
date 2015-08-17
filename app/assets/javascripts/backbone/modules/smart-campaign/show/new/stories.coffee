Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->
  NoChildrenView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/stories/empty_view'

  Show.StoryItemView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/stories/_story'
    tagName: 'li'

    templateHelpers: () ->
      description_line: s.truncate(this.model.get('description'), 30)

  Show.StoriesList = Marionette.CollectionView.extend
    childView: Show.StoryItemView
    emptyView: NoChildrenView
    tagName: "ul"



