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
      influencersSearch: '#find-influencers button'
      authorsKeywordsInput: '#find-authors [name=categories]'
      authorsContactNameInput: '#find-authors [name=contact_name]'
      authorsLocationInput: '#find-authors [name=location]'
      influencersTopicsInput: '#find-influencers [name=topics]'
      influencersLocationInput: '#find-influencers [name=location]'

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
        onText: 'Influencers'
        offText: 'Weibo/Wechat'

    initGeoAutocomplete: ->
      @ui.authorsLocationInput.geocomplete()

    initSelect2: ->
      @ui.authorsKeywordsInput.select2
        placeholder: 'Select a category'
        allowClear: true
        multiple: true
        ajax: {
          url: '/autocompletes/iptc_categories'
          dataType: 'json'
          data: (term, page) ->
            return { term: term }
          results:  (data, page) ->
            return { results: data }
        }

      @ui.influencersTopicsInput.select2
        placeholder: 'Topics'
        multiple: true
        formatResult: (object, container, query) ->
          object.text
        formatSelection: (object, container) ->
          object.text
        id: (object) ->
          object.id
        ajax:
          url: 'autocompletes/iptc_categories'
          dataType: 'JSON'
          data: (term, page) ->
            { term: term }
          results: (data, page) ->
            { results: _(data.skills).map((item) ->
              {
                id: item['id']
                text: item['name']
              }
            ) }
        minimumInputLength: 1
        createSearchChoice: ->
          null
      @ui.influencersLocationInput.select2
        placeholder: 'Locations'
        multiple: false
        formatResult: (object, container, query) ->
          object.text
        formatSelection: (object, container) ->
          object.text.split(',')[0]
        id: (object) ->
          object.id.split(',')[0]
        ajax:
          url: '/autocompletes/locations'
          dataType: 'JSON'
          data: (term, page) ->
            { term: term }
          results: (data, page) ->
            { results: _(data.locations).map((item) ->
              {
                id: item['id']
                text: item['name']
              }
            ) }
        minimumInputLength: 2
        createSearchChoice: ->
          null

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
      })

      Robin.layouts.main.content.currentView.content.currentView.search_view.searchResultRegion.show(@targetKolsSearch)
      @model.set('iptc_categories',params['categories'])
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
      params = {}
      params['topics'] = @ui.influencersTopicsInput.select2('val')
      params['location'] = @ui.influencersLocationInput.select2('val')
      params['typecast'] = @ui.influencersForm.find('[type=radio]:checked').val()

      Robin.vent.trigger 'search:influencers:clicked', params
