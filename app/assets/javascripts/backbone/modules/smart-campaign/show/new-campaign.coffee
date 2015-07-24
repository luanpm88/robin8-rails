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
        if not @data?
          @data = []
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
        data: @data
        parent: @
      _.each @_states, (tab) => @ui[tab].removeClass('active colored')
      _.all @_states, (tab) =>
        @ui[tab].addClass 'active colored'
        tab != s
      @showChildView 'content', @view

    canSetState: (s) ->
      if not @model? and s != 'start'
        return false
      else if @model? and s == 'target' and not @model.get("iptc_categories")?
        return false
      else if @model? and s == 'target' and @model.get("iptc_categories")?
        if @model.get("iptc_categories").length == 0
          return false
      else if @model? and s == 'pitch' and not @model.get("kols")?
        return false
      else if @model? and s == 'pitch' and @model.get("kols")?
        if @model.get("kols").length == 0
          return false
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

