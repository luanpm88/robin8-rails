Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.NewCampaign = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/new-campaign'
    regions:
      content: "#tab-content"

    ui:
      start: '#start-link'
      target: '#target-link'
      pitch: '#pitch-link'

    events:
      "click @ui.start": "start"
      "click @ui.target": "target"
      "click @ui.pitch": "pitch"

    initialize: (options) ->
      @options = options
      @_states = ['start', 'target', 'pitch']
      @empty = false
      @state = @options.state or 'start'
      if not @model?
        @model = new Robin.Models.Campaign()
        @empty = true
        @state = 'start'

    setState: (s) ->
      return if not @canSetState s
      @state = s
      viewClass = switch s
        when 'start' then Show.StartTab
        when 'target' then Show.TargetTab
        when 'pitch' then Show.PitchTab
      @view = new viewClass
        model: @model
        parent: @
      _.each @_states, (tab) => @ui[tab].removeClass('active colored')
      _.all @_states, (tab) =>
        @ui[tab].addClass 'active colored'
        tab != s
      @showChildView 'content', @view

    canSetState: (s) ->
      console.log "HEY! FIX THIS. FIX FIX FIX!!!111"
      return true
      return false if s != 'start' and @empty
      s in @_states

    onRender: () ->
      @setState @state

    start: (e) ->
      e?.preventDefault()
      @setState 'start'

    target: (e) ->
      e?.preventDefault()
      @setState 'target'

    pitch: (e) ->
      e?.preventDefault()
      @setState 'pitch'

