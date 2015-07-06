Robin.module "DashboardKol", (Dashboard, Robin, Backbone, Marionette, $, _)->
  @startWithParent = false

  API =
    showDashboardPage: ()->
      Dashboard.Show.Controller.showDashboardPage()

  Dashboard.on 'start', ()->
      API.showDashboardPage()
      $('#nav-dashboard').parent().addClass('active')
