Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.NewCampaign = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/new-campaign'
    regions:
      content: "#tab-content"

    ui:
      campaignHome: '#campaign-home-link'
      campaignTargets: '#campaign-targets-link'
      campaignPitch: '#campaign-pitch-link'

    events:
      "click #campaign-home-link": "start"
      "click #campaign-targets-link": "targetsShow"
      "click #campaign-pitch-link": "pitchShow"

    initialize: () ->
      @model = if @model? then @model else new Robin.Models.Campaign()

    onShow: () ->
      start_tab = document.getElementById('campaign-home')
      start_tab.className = ' active colored'

    onRender: () ->
      start_tab_view = new Show.StartTab ({
        model: @model
      })
      @showChildView 'content', start_tab_view

    start: () ->
      @ui.campaignHome.className = ' active colored'
      start_tab_view = new Show.StartTab ({
        model: @model
      })
      @showChildView 'content', start_tab_view

    targetsShow: () ->
      @ui.campaignTargets.addClass(' active colored')
      targets_tab_view = new Show.TargetsTab ({
        model: @model
      })
      @showChildView 'content', targets_tab_view

    pitchShow: () ->
      @ui.campaignPitch.addClass(' active colored')
