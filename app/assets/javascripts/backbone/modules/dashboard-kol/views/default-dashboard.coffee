Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->
  Show.DefaultDashboard = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/templates/default-dashboard/default-dashboard'

    regions:
      socialInfluencePower: '.influenceContainer'
      personalInfoRegion: '.personalBody'
      taskRegion: '#default-dashboard-task'
      discover: '#default-dashboard-discover'

    onRender: () ->
      Show.CustomController.showPersonalInfo @getRegion('personalInfoRegion')
      Show.CustomController.showInfluences @getRegion('socialInfluencePower')
      @tasks = new Show.TaskContainer
      @getRegion('taskRegion').show @tasks
      Show.CustomController.showDiscovers @getRegion('discover'), Robin.currentKOL.get('id')


  Show.SocialNotExisted = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/templates/common/social_not_existed'

    initialize: (opts) ->
      @type = opts.type || null

    serializeData: () ->
      type: @type
