Robin.module "DashboardKol", (DashboardKol, Robin, Backbone, Marionette, $, _)->
  @startWithParent = false

  DashboardKol.on 'start', ()->
    @controller = new DashboardKol.Show.Controller()
    @router = new DashboardKol.Router
      controller: @controller
    @controller.showDashboardPage()

  DashboardKol.on 'stop', () ->
    @controller.destroy()
