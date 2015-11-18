Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.ProfileValueListView = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/score-social-value-list'

    ui:
      modal_account: '#modal-account'

    events:
      'click .edit-account': 'editSocialAccount'

    childEvents:
      'save:edit': (childView) ->
        this.triggerMethod 'rerender:socialValue'

    regions:
      modal_account: '#modal-account'

    initialize: (opt) ->
      @parent = opt.parent

    editSocialAccount: (e) ->
      e.preventDefault()
      identity_id = e.target.id
      identity = new Robin.Models.Identity {id: identity_id}
      identity.fetch
        success: (collection, res, opts) =>
          this.showSocialAccount collection

    showSocialAccount: (identity) ->
      if this.getRegion 'modal_account'
        @modal_account_view = new Show.ProfileSocialModalAccount
          model: identity
          title: 'edit_social'
          parent: this
        @showChildView 'modal_account', @modal_account_view
        @ui.modal_account.modal('show')

    serializeData: ->
      items: @collection.toJSON()
