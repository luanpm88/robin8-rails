Robin.module "SmartCampaign", (SmartCampaign, Robin, Backbone, Marionette, $, _) ->
  @startWithParent = false

  SmartCampaign.on 'start', () ->
    $('#nav-smart-campaign').parent().addClass('active')
    @controller = new SmartCampaign.Show.Controller()
    @controller.showPage()
    @router = new SmartCampaign.Router
      controller: @controller

  SmartCampaign.on 'stop', () ->
    @controller.destroy()
