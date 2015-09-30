Robin.module "SmartCampaign", (SmartCampaign, Robin, Backbone, Marionette, $, _) ->
  @startWithParent = false

  SmartCampaign.on 'start', () ->
    $('#nav-smart-campaign').parent().addClass('active')
    @controller = new SmartCampaign.Show.Controller()
    @router = new SmartCampaign.Router
      controller: @controller
    Backbone.history.loadUrl Backbone.history.fragment

  SmartCampaign.on 'stop', () ->
    @controller.destroy()
