Robin.module "DashboardKol", (DashboardKol, Robin, Backbone, Marionette, $, _)->
  @startWithParent = false

  DashboardKol.on 'start', ()->
    $('#nav-dashboard').parent().addClass('active')
    @controller = new DashboardKol.Show.Controller()
    @router = new DashboardKol.Router
      controller: @controller
    @controller.showDashboardPage()
    DashboardKol.history.loadUrl Backbone.history.fragment

  DashboardKol.on 'stop', () ->
    @controller.destroy()
