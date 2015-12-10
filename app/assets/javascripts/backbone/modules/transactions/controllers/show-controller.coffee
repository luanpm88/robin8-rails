#Robin.module 'Transaction.Show', (Show, App, Backbone, Marionette, $, _) ->
#
#  Show.Controller = Marionette.Controller.extend
#    showDashboardPage: ()->
#      @dashboardPageView = new Show.DashboardKOLPage
#      Robin.layouts.main.content.show @dashboardPageView
#
#    showProfile: -> @dashboardPageView.profile()
#    showScore: -> @dashboardPageView.score()
#    showCampaigns: -> @dashboardPageView.campaigns()
#    showDefaultDashboard: -> @dashboardPageView.defaultDashboard()
#
#    # DefaultDashboard
#    initialize: ()->
#      # self = @
#      # self.module = Robin.module('DashboardKol.Show')
#      Robin.vent.on 'showInfluences', () ->
#        @showInfluences()
#        return
#
#    showInfluences: ()->
#      @identities = new Robin.Collections.Identities
#      @influence_view = new Show.Influence
#        collection: @identities
#      @identities.fetch
#        success: (collection, res, opts) =>
#          Show.DefaultDashboard.regions.socialInfluencePower.show @influence_view
#
#    showInfluenceItem: (collection, influence)->
#      if influence
#        item = influence
#      else if collection.models[0]
#        item = new Robin.Models.SocialInfluence {id: collection.models[0].get('id')}
#      else
#        missingView = new Show.SocialNotExisted
#        Show.DefaultDashboard.regions.item.show missingView
#        return
#      itemView = new Show.InfluenceItem
#        model: item
#      fetchingItem = item.fetch()
#      $.when(fetchingItem).done((data, textStatus, jqXHR)->
#        if data.result != 'fail'
#          Show.DefaultDashboard.regions.item.show itemView
#        else
#          Show.DefaultDashboard.regions.item.show missingView
#      ).fail(
#        Show.DefaultDashboard.regions.item.show missingView
#      )
#
#    showDiscover: (label)->
#      @discovers = new Robin.Collections.Discovers
#        labe: label
#      @discovers_view = new Show.Discovers
#        collection: @discovers
#      Show.DefaultDashboard.regions.discover.show @discovers_view
