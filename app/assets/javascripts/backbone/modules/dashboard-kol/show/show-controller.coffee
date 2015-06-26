Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller =
    showDashboardPage: ()->
      invites = new Robin.Collections.CampaignInvitations()
      invites.fetch
        success: ()->
          dashboardPageView.render()
        error: ()->
          console.log "pizdanulis"

      dashboardPageView = new Show.DashboardKOLPage(
        collection: invites
      )

      Robin.layouts.main.content.show dashboardPageView

