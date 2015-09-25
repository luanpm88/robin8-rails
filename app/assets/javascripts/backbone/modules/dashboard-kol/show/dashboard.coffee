Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.DashboardKOLPage = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/dashboard'

    regions:
      content: "#tab-content"

    ui:
      profile: '#profile-link'
      score: '#score-link'
      campaigns: '#campaigns-link'

    initialize: (options) ->
      @options = options
      @_states = ['profile', 'score', 'campaigns']
      @empty = false
      @state = @options.state or 'campaigns'
      if not @model?
        @model = new Robin.Models.KOL()
        if not @data?
          @data = []
        @empty = true

    setState: (s) ->
      return if not @canSetState s
      @state = s
      viewClass = switch s
        when 'profile' then Show.ProfileTab
        when 'score' then Show.ScoreTab
        when 'campaigns' then Show.CampaignsTab
      @view = new viewClass
        model: @model
        data: @data
        parent: @
      _.each @_states, (tab) => @ui[tab].removeClass('active colored')
      _.all @_states, (tab) =>
        @ui[tab].addClass 'active colored'
        tab != s
      @showChildView 'content', @view
      _.defer =>
        $('#sidebar li.active, #sidebar-bottom li.active').removeClass('active')
        if @state == "campaigns"
          $('#nav-campaigns').parent().addClass('active')
        if @state == "profile"
          $('#nav-sidebar-profile').parent().addClass('active')

    canSetState: (s) ->
      s in @_states

    onRender: () ->
      @setState @state

    profile: (e) ->
      e?.preventDefault()
      @setState 'profile'

    score: (e) ->
      e?.preventDefault()
      @setState 'score'

    campaigns: (e) ->
      e?.preventDefault()
      @setState 'campaigns'
