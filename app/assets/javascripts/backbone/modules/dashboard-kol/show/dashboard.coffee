Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.DashboardKOLPage = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/dashboard'

    regions:
      content: "#tab-content"

    ui:
      social: '#social-link'
      score: '#score-link'
      campaigns: '#campaigns-link'

    events:
      "click @ui.social": "social"
      "click @ui.score": "score"
      "click @ui.campaigns": "campaigns"

    initialize: (options) ->
      @options = options
      @_states = ['social', 'score', 'campaigns']
      @empty = false
      @state = @options.state or 'social'
      if not @model?
        @model = new Robin.Models.KOL()
        if not @data?
          @data = []
        @empty = true
        @state = 'social'

    setState: (s) ->
      return if not @canSetState s

      @state = s

      viewClass = switch s
        when 'social' then Show.SocialTab
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

    canSetState: (s) ->
      return true
      s in @_states

    onRender: () ->
      @setState @state

    social: (e) ->
      e?.preventDefault()
      @setState 'social'

    score: (e) ->
      e?.preventDefault()
      @setState 'score'

    campaigns: (e) ->
      e?.preventDefault()
      @setState 'campaigns'
