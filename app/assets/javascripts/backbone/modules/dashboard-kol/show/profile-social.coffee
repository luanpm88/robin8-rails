Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.ProfileSocialView = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/profile-social'

    initialize: (opts) ->
      @model_binder = new Backbone.ModelBinder()

    onRender: ->
      @model_binder.bind @model, @el

