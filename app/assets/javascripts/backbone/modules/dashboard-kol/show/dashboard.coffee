Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.DashboardKOLPage = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/dashboard'
    events:
      "click .invitation-accept": "accept"
      "click .invitation-decline": "decline"

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        date.toLocaleFormat '%d-%b-%Y'
      timestamp: (d) ->
        date = new Date d
        date.getTime()

    accept: (event) ->
      event.preventDefault()
      @perform_action($(event.currentTarget))

    decline: (event) ->
      event.preventDefault()
      @perform_action($(event.currentTarget), "decline")

    perform_action: (button, action="accept") ->
      self = this
      button_container = button.parent().parent()
      id = button.data("inviteId")
      item = self.collection.get(id)
      action_method = if action == "accept" then item.accept() else item.decline()
      $.when(action_method).then ()->
        button_container.remove()
        self.render()

    onRender: () ->
      invitesTable = @$el.find('#kol-dashboard')
      if invitesTable[0]
        invitesTable.stupidtable()
