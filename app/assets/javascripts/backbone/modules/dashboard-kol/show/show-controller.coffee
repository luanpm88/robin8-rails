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
    showInfluencesAndDiscovers: (influenceRegion, discoverRegion) ->
      socialList = new Robin.Collections.Identities
      influences_view = new Show.Influence
        collection: socialList
      socialList.fetch
        success: (collection, res, opts) =>
          influenceRegion.show influences_view

          if collection.models[0]
            @showDiscover collection.models[0].get('id'), discoverRegion
          else
            @showDiscover null, discoverRegion

    appendMoreDiscovers: (region) ->
      el = region.$el
      currentPage = el.find('ul').children('li').length / 10
      return if currentPage == 0
      nextPage = currentPage + 1
      labels = region.currentView.collection.labels
      @showDiscoverFor labels, region, nextPage

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

    showDiscover: (socialAccountId, region)->
      if socialAccountId
        socialAccount = new Robin.Models.SocialInfluence {id: socialAccountId}
        socialAccount.fetch
          success: (model, res, opts) =>
            if res.result != 'fail'
              temp_labels = ''
              for label in model.get('labels')
                temp_labels = temp_labels + label.name + ','
              labels = temp_labels[0...-1]
              @showDiscoverFor labels, region
            else
              labels = 'all'
              @showDiscoverFor labels, region
          error: =>
            labels = 'all'
            @showDiscoverFor 'all', region
      else
        @showDiscoverFor 'all', region

    showDiscoverFor: (labels, region, page) ->
      console.log 'exec showDiscoverFor: ', labels, region, page
      page = page || 1
      discovers = new Robin.Collections.Discovers [], {labels: labels, page: page}
      discoversView = new Show.DiscoversLayout
        collection: discovers
        parentRegion: region
      discovers.fetch
        success: (collection, res, opts) =>
          if region.$el.find('ul').children().length == 0
            region.show discoversView
          else
            $('#loadingDiscover').hide()
            region.currentView.$el.find('ul').append discoversView.render().$el.find('ul').children()
        error: =>
          console.log 'fetch discover error'

  }
