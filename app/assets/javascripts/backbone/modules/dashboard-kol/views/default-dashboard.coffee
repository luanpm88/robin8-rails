Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.DefaultDashboard = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/default-dashboard'

    regions:
      socialInfluencePower: '#social-influence-power'
      taskRegion: '#default-dashboard-task'
      discover: '#default-dashboard-discover'

    onRender: () ->
      @tasks = new Show.Tasks
      @getRegion('taskRegion').show @tasks
      kol = new Robin.Models.KOL
      kol.fetch
        success: (model, res, opts) =>
          Show.CustomController.showInfluencesAndDiscovers(@getRegion('socialInfluencePower'), @getRegion('discover'), kol.get('id'))


  Show.SocialNotExisted = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/templates/common/social_not_existed'

    initialize: (opts) ->
      @type = opts.type || null

    serializeData: () ->
      type: @type
