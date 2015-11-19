Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  # ItemView must declared before CompositeView!!!
  Show.ProfileCompletionListView = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/profile-completion-item'
    tagName: 'div'

  Show.ProfileCompletionView = Backbone.Marionette.CompositeView.extend
    template: 'modules/dashboard-kol/show/templates/profile-completion-list'
    tagName: 'div'

    childView: Show.ProfileCompletionListView
    childViewContainer: 'div.js-itemContainer'
