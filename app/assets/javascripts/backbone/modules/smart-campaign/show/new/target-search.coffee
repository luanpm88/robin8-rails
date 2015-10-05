Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.SearchLayout = Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/search-campaign-layout'

    regions:
      searchCriteriaRegion: '#search-criteria'
      searchResultRegion: '#search-result'

    initialize: (options) ->
      @model = @options.model
      @searchCriteriaView = new Show.SearchCriteriaView({
        model: @model
      })

    onRender: ->
      @showChildView 'searchCriteriaRegion', @searchCriteriaView

  Show.SearchCriteriaView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/search-campaign-criteria'
    tagName: 'div'
    className: 'panel panel-success'

    ui:
      checkbox: '[type="checkbox"]'
      authorsForm: '#find-authors'
      influencersForm: '#find-influencers'
      title: '.panel-title strong'
      authorsSearch: '#find-authors button'
      influencersSearch: '#weibo-search'
      authorsKeywordsInput: '#find-authors [name=search_categories]'
      authorsContactNameInput: '#find-authors [name=contact_name]'
      authorsLocationInput: '#find-authors [name=location]'
      influencersTopicsInput: '#find-influencers [name=topics]'
      influencersLocationInput: '#find-influencers [name=weibo_location]'

    events:
      'switchChange.bootstrapSwitch @ui.checkbox': 'changeFinder'
      'click @ui.authorsSearch': 'searchAuthors'
      'click @ui.influencersSearch': 'searchInfluencers'

    initialize: (options) ->
      @model = @options.model

    onShow: ->
      @initSwitch()
      @initSelect2()
      @initGeoAutocomplete()
      @on 'authors:select', @authorsSelect
      @on 'influencers:select', @influencersSelect

    initSwitch: ->
      @ui.checkbox.bootstrapSwitch
        size: 'mini'
        onColor: 'info'
        offColor: 'info'
        onText: polyglot.t('smart_campaign.targets_step.influencers')
        offText: 'Weibo'

    initGeoAutocomplete: ->
      @ui.authorsLocationInput.geocomplete()

    initSelect2: ->
      @ui.authorsKeywordsInput.select2
        allowClear: true
        multiple: true
        formatInputTooShort: (input, min) ->
          n = min - input.length
          return polyglot.t("select2.too_short", {count: n})
        formatNoMatches: () ->
          return polyglot.t("select2.not_found")
        formatSearching: () ->
          return polyglot.t("select2.searching")
        ajax: {
          url: '/autocompletes/iptc_categories'
          dataType: 'json'
          data: (term, page) ->
            return { term: term }
          results:  (data, page) ->
            return { results: data }
        }

      @ui.influencersLocationInput.geocomplete()

    changeFinder: (event, state) ->
      if state
        @trigger 'authors:select'
      else
        @trigger 'influencers:select'

    changeTitle: (text) ->
      @ui.title.text text

    authorsSelect: ->
      @changeTitle ' Search Authors'
      @ui.authorsForm.removeClass 'hide'
      @ui.influencersForm.addClass 'hide'

    influencersSelect: ->
      @changeTitle ' Search Influencers'
      @ui.authorsForm.addClass 'hide'
      @ui.influencersForm.removeClass 'hide'

    searchAuthors: (event) ->
      event.preventDefault()
      params = {}
      params['categories'] = @ui.authorsKeywordsInput.select2('val')
      params['contactName'] = @ui.authorsContactNameInput.val()
      params['location'] = @ui.authorsLocationInput.val()

      self = this

      @search_view = new Show.SearchLayout({
        model: self.model
      })

      Robin.layouts.main.content.currentView.content.currentView.search_view.searchResultRegion.show(
        new Robin.Components.Loading.LoadingView()
      )

      self.targetKolsSearch = new Show.TargetKols({
        model: self.model
        search: true
      })

      Robin.layouts.main.content.currentView.content.currentView.search_view.searchResultRegion.show(@targetKolsSearch)
      #@model.set('iptc_categories',params['categories'])
      $.get "/kols/suggest/", {categories: params['categories'], name: params['contactName'], location: params['location']}, (data) =>
        @targetKolsSearch.updateKols data
        @targetKolsSearch.render()

    getKols: ()->
      if @targetKolsSearch?
        kols_valid = @targetKolsSearch.validate()
        if kols_valid
          return @targetKolsSearch.invitedKols()

    searchInfluencers: (event) ->
      event.preventDefault()

      keywords = $('#find-influencers [name=topics]').val()
      location = @ui.influencersLocationInput.val()

      @search_view = new Show.SearchLayout({
        model: @model
      })

      @weibo_view = new Show.TargetWeibo(
        model: @model
      )

      Robin.layouts.main.content.currentView.content.currentView.search_view.searchResultRegion.show(
        new Robin.Components.Loading.LoadingView()
      )

      Robin.layouts.main.content.currentView.content.currentView.search_view.searchResultRegion.show(@weibo_view)

      $.post "/robin8_api/filter_authors", {per_page: 100, included_email: true, type: "weibo", location: location, keywords: keywords}, (data) =>
        @weibo_view.updateWeibo data
        @weibo_view.setCampaignModel @model
        @weibo_view.render()
