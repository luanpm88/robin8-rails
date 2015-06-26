Robin.module "Campaigns", (Campaigns, Robin, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    showPage: ()->
      Campaigns.Show.Controller.showPage()

  Campaigns.on 'start', () ->
      API.showPage()
      $('#nav-campaigns').parent().addClass('active')
