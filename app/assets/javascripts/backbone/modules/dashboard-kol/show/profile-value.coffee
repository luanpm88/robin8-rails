Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.ProfileSocialValueContainer = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/social-value-layout'

    ui:
      modal_account: '#modal-account'

    regions:
      modal_account: '#modal-account'
      container: '#value-data-group'

    initialize: () ->
      @social_values = new Show.ProfileSocialValueList
        collection: @collection
      parentThis = this
      @social_values.on 'childview:edit:account', (childView, model) ->
        parentThis.showModal model

    showModal: (model) ->
      if @getRegion 'modal_account'
        @modal_account_view = new Show.ProfileSocialModalAccount
          model: model
          parent: this
          title: 'edit_social'
        @getRegion('modal_account').show @modal_account_view
        @ui.modal_account.modal 'show'

    onRender: () ->
      @getRegion('container').show @social_values

  Show.ProfileSocialValueItem = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/social-value-item'

    events:
      'click .edit-account': 'editSocialAccount'

    initialize: () ->
      _.bindAll(this, 'render')
      @model.on('change', @render, this);

    editSocialAccount: (e) ->
      e.preventDefault()
      @trigger 'edit:account', @model

  Show.ProfileSocialValueList = Backbone.Marionette.CollectionView.extend
    childView: Show.ProfileSocialValueItem
