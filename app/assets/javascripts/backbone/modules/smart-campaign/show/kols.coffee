Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.Kols = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/kols'

    templateHelpers:
      active: (k) ->
        if k.active then "Yes" else "No"
      categories: (k) ->
        res = _(k.categories).map (c) ->
          context = { label: c.label }
          Show.KolCategoriesTemplate context
        res.join ''

    ui:
      categories: "#categories"
      add: "#add_kol_confirm"
      form: "#add_kol-form"
      tooltipFormatInfo: "[data-toggle=tooltip]"
      table: "#private_kols-table"
      fileInput: "#private_kols_file"

    events:
      "click #invite_kols": "inviteKols"
      "change @ui.fileInput": "import_csv"
      'click #add_kol': 'openModalDialog'
      "click @ui.add": "add"

    collectionEvents:
      "add and reset add remove": "render"

    import_csv: () ->
      $.ajax
        url: 'users/import_kols'
        type: 'POST'
        data: new FormData document.getElementById("invite_kols_form")
        cache: false
        processData: false
        contentType: false
        success: =>
          @collection.fetch()

          $.growl({message: "Your list has been successfully uploaded."
          },{
            type: 'success'
          })

          $.growl({message: "All contacts in incorrect format will be ignored."
          },{
            type: 'info'
          })
        error: (res) ->
          if res && res.responseJSON
            errorField = _.keys(res.responseJSON)[0]
            errorMessage = res.responseJSON.message
            errorField = s.capitalize errorField.replace(/_/g,' ')

            $.growl {message: errorField + ': ' + errorMessage}, type: 'danger'

    inviteKols: (e) ->
      e.preventDefault()
      this.ui.fileInput.trigger "click"

    onRender: () ->
      @initTooltip()
      @ui.table.DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 25
      @ui.form.validator()
      @ui.categories.select2
        placeholder: "Select influencer categories"
        multiple: true
        minimumInputLength: 1
        maximumSelectionSize: 10
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

