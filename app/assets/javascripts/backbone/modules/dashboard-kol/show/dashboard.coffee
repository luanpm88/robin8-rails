Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.DashboardKOLPage = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/dashboard'

    regions:
      content: "#tab-content"

    ui:
      profile: '#profile-link'
      score: '#score-link'
      campaigns: '#campaigns-link'
      default: '#default-link'

    initialize: (options) ->
      @options = options
      @_states = ['profile', 'score', 'campaigns', 'default']
      @empty = false
      @state = @options.state or 'CRASH AND BURN'
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
        when 'default' then Show.DefaultDashboard
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
        if s == "campaigns"
          $('.dashboard-tabs').remove()
        if s == "profile"
          $('li#score-link, li#profile-link').show()
          $('#nav-sidebar-profile').parent().addClass('active')
          $('li#default-link').hide()
        if s == 'default'
          $('li#default-link').show()
          $('li#default-link a').css({'border-radius': '4px'})
          $('li#score-link, li#profile-link').hide()
        state_url = ({
          profile: "dashboard/profile"
          score: "dashboard/score"
          campaigns: "dashboard/campaigns"
          default: 'dashboard/default'
        })[s]
        if location.hash != state_url
          history.pushState({}, "", "#/#{state_url}")
          Backbone.history.fragment = state_url

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

    defaultDashboard: (e) ->
      e?.preventDefault()
      @setState 'default'
