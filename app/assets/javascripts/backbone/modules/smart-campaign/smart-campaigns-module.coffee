Robin.module "SmartCampaign", (SmartCampaign, Robin, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    showPage: ()->
      SmartCampaign.Show.Controller.showPage()

  SmartCampaign.on 'start', () ->
      API.showPage()
      $('#nav-smart-campaign').parent().addClass('active')
