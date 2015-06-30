Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.DashboardKOLPage = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/dashboard'
    events:
      "click .invitation-actions": "actions_clicked"
    actions_clicked: (event) ->
      event.preventDefault()
      button = $(event.currentTarget)
      button_container = button.parent().parent()
#      loading_view = new Robin.Components.Loading.LoadingView()
#      button_container.html(loading_view.render())
      id = button.data("inviteId")
      action = button.data("action")
      item = this.collection.get(id)
      if action == "accept" then item.accept() else item.decline()
