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
          parentThis.showDiscover(discoverRegion, userId)
          socialList = new Robin.Collections.Identities
          influences_view = new Show.Influence
            collection: socialList
            score_data: data
          socialList.fetch
            success: (collection, res, opts) =>
              influenceRegion.show(influences_view)
        error: (xhr, textStatus) ->

    appendMoreDiscovers: (region) ->
      el = region.$el
      currentPage = el.find('ul').children('li').length / 10
      return if currentPage == 0
      nextPage = currentPage + 1
      labels = region.currentView.collection.labels
      @showDiscoverFor(labels, region, nextPage)

    showInfluenceItem: (influence, influences, region) ->
      influences.remove influences.where({provider: 'wechat'})
      if influence
        item = influence
      else if influences.models[0]
        item = new Robin.Models.SocialInfluence {id: influences.models[0].get('id')}
      else
        missingView = new Show.SocialNotExisted
          type: 'nothing'
        region.show(missingView)
        return

      missingView = new Show.SocialNotExisted
      influenceView = new Show.InfluenceItem
        model: item

      fetchingItem = item.fetch()
      $.when(fetchingItem).done((data, textStatus, jqXHR)->
        if data.result != 'fail'
          region.show(influenceView)
        else
          mView = new Show.SocialNotExisted
            type: data.provider
          region.show(mView)
      ).fail(->
        region.show(missingView)
      )

    showDiscover: (region, userId)->
      labels = new Robin.Models.UserLabels {id: userId}
      labels.fetch
        success: (model, res, opts) =>
          if model.get('labels_string') == ''
            model.set('labels_string', 'all')
          @showDiscoverFor(model.get('labels_string'), region)
        error: =>
          console.log 'fire showDiscover: fetch labels error'
          @showDiscoverFor('all', region)

    getAccountLabelsBy: (id) ->
      labels = ''
      socialAccount = new Robin.Models.SocialInfluence({id: id})
      socialAccount.fetch
        success: (model, res, opts) =>
          if res.result != 'fail'
            for label in model.get('labels')
              labels = labels + label.name + ','
            labels = labels[0...-1]
          else
            labels = 'all'
        error: =>
          console.log 'fire getAccountLabelsBy: fetch socialAccount error'
          labels = 'all'
      return labels

    showDiscoverFor: (labels, region, page) ->
      console.log 'exec showDiscoverFor: ', labels, region, page
      page = page || 1
      discovers = new Robin.Collections.Discovers([], {labels: labels, page: page})
      discoversView = new Show.DiscoversLayout
        collection: discovers
        parentRegion: region
      if region.$el.find('ul').children().length == 0
        region.show(discoversView)
      else
        discovers.fetch
          success: (collection, res, opts) =>
            region.currentView.$el.find('ul').append(discoversView.render().$el.find('ul').children())
          error: =>
            console.log 'fire showDiscoverFor: fetch discover error'

  }
