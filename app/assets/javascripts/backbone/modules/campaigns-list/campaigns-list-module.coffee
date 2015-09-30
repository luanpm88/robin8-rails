Robin.module "CampaignsList", (CampaignsList, Robin, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    showPage: ()->
      CampaignsList.Show.Controller.showPage()

  CampaignsList.on 'start', () ->
    API.showPage()
    $('#nav-campaignslist').parent().addClass('active')
