Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.Controller = Marionette.Controller.extend
    showDashboardPage: ()->
      @dashboardPageView = new Show.DashboardKOLPage
      Robin.layouts.main.content.show @dashboardPageView

    showProfile: -> @dashboardPageView.profile()
    showScore: -> @dashboardPageView.score()
    showCampaigns: -> @dashboardPageView.campaigns()
    showDefaultDashboard: -> @dashboardPageView.defaultDashboard()


  Show.CustomController = {
    showInfluences: (region) ->
      socialList = new Robin.Collections.Identities
      influences_view = new Show.Influence
        collection: socialList
      socialList.fetch
        success: (collection, res, opts) =>
          region.show influences_view

    showInfluenceItem: (influence, influences, region) ->
      if influence
        item = influence
      else if influences.models[0]
        item = new Robin.Models.SocialInfluence {id: influences.models[0].get('id')}
      else
        missingView = new Show.SocialNotExisted
        region.show missingView
        return

      missingView = new Show.SocialNotExisted
      influenceView = new Show.InfluenceItem
        model: item

      fetchingItem = item.fetch()
      $.when(fetchingItem).done((data, textStatus, jqXHR)->
        if data.result != 'fail'
          region.show influenceView
        else
          region.show missingView
      ).fail(->
        region.show missingView
      ) 

    showDiscover: (region)->
      discovers = new Robin.Collections.Discovers
      discovers_view = new Show.DiscoversLayout
        collection: discovers
      discovers.fetch
        success: (collection, res, opts) =>
          region.show discovers_view
  }


