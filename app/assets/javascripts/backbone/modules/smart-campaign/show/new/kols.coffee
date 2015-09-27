Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.KolCategoriesTemplate = _.template '<span class="kol‐category"><%= label %></span>'

  Show.Kols = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/kols/kols'

    regions:
      influencersRegion: '#targets-blogs'
      influencersListRegion: '#targets-list'

    ui:
      categories: "#categories"
      add: "#add_kol_confirm"
      form: "#add_kol-form"
      tooltipFormatInfo: "[data-toggle=tooltip]"
      fileInput: "#private_kols_file"
      
    collectionEvents:
      "add and reset add remove": "render"

    events:
      "click #invite_kols": "inviteKols"
      "change @ui.fileInput": "import_csv"
      'click #add_kol': 'openModalDialog'
      "click @ui.add": "add"

    import_csv: (e) ->
      $.ajax
        url: 'users/import_kols'
        type: 'POST'
        data: new FormData document.getElementById("invite_kols_form")
        cache: false
        processData: false
        contentType: false
        dataType: 'JSON'
        success: (res) =>

          $.growl({message: polyglot.t('smart_campaign.kol.list_uploaded')
          },{
            type: 'success'
          })

          $.growl({message: polyglot.t('smart_campaign.kol.incorrect_ignored')
          },{
            type: 'info'
          })
          if res.kols_count == 0
            $.growl({message: polyglot.t('smart_campaign.kol.empty_list')
            },{
              type: 'danger'
            })
          else
            kols_list = new Robin.Collections.KolsLists()
            kols_list_view = new Show.KolsList
              collection: kols_list
            kols_list.fetch
              success: (c, r, o) =>
                @showChildView 'influencersListRegion', kols_list_view

        error: (res) ->
          if res && res.responseJSON
            errorField = _.keys(res.responseJSON)[0]
            errorMessage = res.responseJSON.message
            errorField = s.capitalize errorField.replace(/_/g,' ')
            if errorField == 'Error'
              errorField = polyglot.t('smart_campaign.kol.error')
            $.growl {message: errorField + ': ' + errorMessage}, type: 'danger'

    inviteKols: (e) ->
      e.preventDefault()
      this.ui.fileInput.trigger "click"

    onRender: () ->
      @initTooltip()
      @ui.form.validator()
      @ui.categories.select2
        placeholder: polyglot.t('smart_campaign.kol.select_categories')
        multiple: true
        minimumInputLength: 1
        maximumSelectionSize: 10
        formatInputTooShort: (input, min) ->
          n = min - input.length
          return polyglot.t("select2.too_short", {count: n})
        formatNoMatches: () ->
          return polyglot.t("select2.not_found")
        formatSearching: () ->
          return polyglot.t("select2.searching")
        ajax:
          url: "/kols/suggest_categories"
          dataType: 'json'
          quietMillis: 250
          data: (term) ->
            f: term
          results: (data) ->
            results: data
          cache: true
        escapeMarkup: _.identity

    initTooltip: () ->
      @ui.tooltipFormatInfo.tooltip
        trigger: 'hover'

    openModalDialog: () ->
      $("#kol_form input").val("")
      @ui.categories.select2 "data", {}
      $('.select2-search-choice').remove()
      @$el.find('#kol_form').modal keyboard: false

    add: () ->
      @ui.form.validator('validate')
      form_valid = $(".form-group.with-errors").length == 0
      if form_valid
        data = _.reduce $("#add_kol-form").serializeArray(), ((m, i) -> m[i.name] = i.value; m), {}
        $.post "/users/import_kol/", data, (data) =>
          if data.status == "ok"
            $("#kol_form").modal("hide")
            $('#kol_form').on 'hidden.bs.modal', () =>
              @collection.fetch()
          else
            $.growl {message: data.status}, {type: 'danger'}

  Show.KolsView = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/kols/kols_view'

    templateHelpers:
      active: (k) ->
        if k.active then polyglot.t('smart_campaign.yes') else polyglot.t('smart_campaign.no')
      categories: (k) ->
        res = _(k.categories).map (c) ->
          context = { label: c.label }
          Show.KolCategoriesTemplate context
        res.join ''

    ui:
      table: "#private_kols-table"

    collectionEvents:
      "add and reset add remove": "render"

    onRender: () ->
      @ui.table.DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 25
        language:
          paginate:
            previous: polyglot.t('smart_campaign.prev'),
            next: polyglot.t('smart_campaign.next')

  Show.KolsList = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/kols/kols_list'

    ui:
      table: "#private_kols-table"
      deleteButton: 'a.btn-danger'
      
    collectionEvents:
      "add and reset add remove": "render"

     events:
      'click @ui.deleteButton': 'deleteButtonClicked'

    onRender: () ->
      @ui.table.DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 25
        language:
          paginate:
            previous: polyglot.t('smart_campaign.prev'),
            next: polyglot.t('smart_campaign.next')

    templateHelpers:
      count: (items) ->
        c = 0
        $(items).each(() ->
          if this.invited == true
            c = c + 1
        )
        return c

    deleteButtonClicked: (e) ->
      e.preventDefault()
      target = $ e.currentTarget
      kol_id = target.data 'list-id'
      data = {}
      data['id'] = kol_id
      swal {
        title: polyglot.t('smart_campaign.targets_step.delete_list')
        type: 'error'
        showCancelButton: true
        confirmButtonClass: 'btn-danger'
        confirmButtonText: polyglot.t('billing.cancel.yes')
        cancelButtonText: polyglot.t('billing.cancel.no')
      }, (isConfirm) =>
        if isConfirm
          $.ajax
            type: 'DELETE'
            url: '/users/delete_kols_list'
            dataType: 'json'
            data: data
            success: () =>
              kols_list = new Robin.Collections.KolsLists()
              kols_list_view = new Show.KolsList
                collection: kols_list
              kols_list.fetch
                success: (c, r, o) =>
                  Robin.layouts.main.content.currentView.kols.currentView.influencersListRegion.show(kols_list_view)

