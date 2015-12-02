Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.DefaultDashboard = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/default-dashboard/default-dashboard'

    regions:
      socialInfluencePower: '#social-influence-power'
      campaign: '#default-dashboard-campaign'
      discover: '#default-dashboard-discover'

    onRender: () ->
      kol = new Robin.Models.KOL
      kol.fetch
        success: (model, res, opts) =>
          Show.CustomController.showInfluencesAndDiscovers(@getRegion('socialInfluencePower'), @getRegion('discover'), kol.get('id'))


  Show.SocialNotExisted = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/common/social_not_existed'

    initialize: (opts) ->
      @type = opts.type || null

    serializeData: () ->
      type: @type
