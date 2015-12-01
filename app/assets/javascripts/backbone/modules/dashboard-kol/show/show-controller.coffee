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
    showInfluencesAndDiscovers: (influenceRegion, discoverRegion, userId) ->
      parentThis = @
      $.ajax
        type: "get"
        url: '/kols/get_score',
        dataType: 'json',
        success: (data) ->
          socialList = new Robin.Collections.Identities
          influences_view = new Show.Influence
            collection: socialList
            score_data: data
          socialList.fetch
            success: (collection, res, opts) =>
              influenceRegion.show influences_view

              if collection.models[0]
                parentThis.showDiscover collection.models[0].get('id'), discoverRegion, userId
              else
                parentThis.showDiscover null, discoverRegion, userId
        error: (xhr, textStatus) ->


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
          type: 'nothing'
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
          mView = new Show.SocialNotExisted
            type: data.provider
          region.show mView
      ).fail(->
        region.show missingView
      )

    showDiscover: (socialAccountId, region, userId)->
      labels = new Robin.Models.UserLabels {id: userId}
      labels.fetch
        success: (model, res, opts) =>
          @showDiscoverFor model.get('labels_string'), region
        error: =>
          @showDiscoverFor 'all', region

      # if socialAccountId
      #   socialAccount = new Robin.Models.SocialInfluence {id: socialAccountId}
      #   socialAccount.fetch
      #     success: (model, res, opts) =>
      #       if res.result != 'fail'
      #         temp_labels = ''
      #         for label in model.get('labels')
      #           temp_labels = temp_labels + label.name + ','
      #         labels = temp_labels[0...-1]
      #       else
      #         labels = 'all'
      #       @showDiscoverFor labels, region
      #     error: =>
      #       labels = 'all'
      #       @showDiscoverFor labels, region
      # else if userId

      # else
      #   @showDiscoverFor 'all', region

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
