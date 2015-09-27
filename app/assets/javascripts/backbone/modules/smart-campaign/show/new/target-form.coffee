Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.TargetTab = Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/targets-tab'

    ui:
      categories: "#categories"
      select: "select.releases"
      nextButton: '#next-step'
      targetsWeiboTab: '#targets-weibo-tab'
      categoriesInput: 'input[name=categories]'
      selectForm: '#selectForm'

    regions:
      #wechatRegion: "#targets-wechat"
      weiboRegion: "#targets-weibo"
      blogsRegion: "#targets-blogs"
      searchRegion: "#targets-search"
      kolsListRegion: "#kolslist-upload"

    events:
      'click @ui.nextButton': 'openPitchTab'
      'select2-removed @ui.categoriesInput': 'removeCategory'
      'select2-selecting @ui.categoriesInput': 'addCategory'

    initialize: (options) ->
      @model = if @options.model? then @options.model else new Robin.Models.Campaign()
      @weibo_view = new Show.TargetWeibo(
        model: @model
      )
      @targets_view = new Show.TargetKols(
        model: @model
      )
      @search_view = new Show.SearchLayout(
        model: @model
      )
      @kolslist_view = new Show.KolsListLayout(
        model: @model
      )

      #@wechat_view = new Show.TargetWechat()


    openPitchTab: () ->
      @options.parent.setState('pitch')

    removeCategory: (e) ->
      iptc_categories = @model.get('iptc_categories')
      if iptc_categories.indexOf(e.val) > -1
        iptc_categories.pop(e.val)
        @model.set('iptc_categories',iptc_categories)
        $('#selectForm').formValidation('revalidateField', 'categories')
        if $('#selectForm').data('formValidation').isValid()
          @weibo_view = new Show.TargetWeibo(
            model: @model
          )
          @targets_view = new Show.TargetKols(
            model: @model
          )
          @search_view = new Show.SearchLayout(
            model: @model
          )
          @render()

    addCategory: (e) ->      
      iptc_categories = @model.get('iptc_categories')
      if iptc_categories.indexOf(e.val) < 0
        iptc_categories.push(e.val)
        @model.set('iptc_categories',iptc_categories)
        $('#selectForm').formValidation('revalidateField', 'categories')
        if $('#selectForm').data('formValidation').isValid()
          @weibo_view = new Show.TargetWeibo(
            model: @model
          )
          @targets_view = new Show.TargetKols(
            model: @model
          )
          @search_view = new Show.SearchLayout(
            model: @model
          )
          @render()


    onRender: () ->
      @ui.selectForm.ready(@initFormValidation())

      self = this

      @showChildView 'kolsListRegion', @kolslist_view
      #@showChildView 'wechatRegion', @wechat_view
      @showChildView 'weiboRegion', @weibo_view
      @showChildView 'blogsRegion', @targets_view
      @showChildView 'searchRegion', @search_view

      iptc_categories = @model.get('iptc_categories')
      $.get "/kols/suggest/", {categories: iptc_categories}, (data) =>
        @targets_view.updateKols data
        @targets_view.render()
      if @model.get("kols")?
        if @model.get("kols").length > 0
          @ui.nextButton.removeAttr('disabled')
      else if @model.get("weibo")?
        if @model.get("weibo").length > 0
          @ui.nextButton.removeAttr('disabled')


      params = {description: @model.get("description")}
      $.ajax({
        dataType: 'json',
        method: 'POST',
        url: '/campaign/get_counter/',
        data: params,
        async:   false
        success: (response)->
          self.model.set("counter", response)
      })

      params = {title: @model.get("name"), body: @model.get("description"), per_page: 100, included_email: true, type: "weibo", published_at: "[* TO *]"}
      $.post "/robin8_api/suggested_authors", {title: @model.get("name"), body: @model.get("description"), per_page: 100, included_email: true, type: "weibo", published_at: "[* TO *]"}, (data) =>
        @weibo_view.updateWeibo data
        @weibo_view.setCampaignModel @model
        @weibo_view.render()
        #$el.find('#targets-weibo-tab').click()
        @ui.targetsWeiboTab.click()

      self.ui.categoriesInput.select2
        allowClear: false
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
        initSelection: (el, callback) =>
          @ui.categoriesInput.val 'val'
          $.get "/kols/get_categories_labels/", {categories_id: @model.get('iptc_categories')}, (data) =>
            callback data
        @ui.categoriesInput.val 'val'
        @ui.categoriesInput.trigger("change");

    initFormValidation: () ->
      @ui.selectForm.formValidation
        framework: 'bootstrap'
        excluded: ':disabled'
        icon:
          valid: 'glyphicon glyphicon-ok'
          invalid: 'glyphicon glyphicon-remove'
          validating: 'glyphicon glyphicon-refresh'
        fields: categories: validators: callback:
          message: polyglot.t('smart_campaign.targets_step.choose_category')
          callback: (value, validator, $field) ->
            options = $field.val()
            options2 = options.split(',')
            options2.length > 1


    transformLabel: (label, code) ->
      if code.substring(0, 2) == "16"
        label = "Society - Issue"

      if code == "12001000"
        label = "Arts, Culture and Entertainment - Culture"

      return label
