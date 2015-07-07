Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.Kols = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/kols'

    ui:
      table: "#private_kols-table"
      fileInput: "#private_kols_file"

    events:
      "click #invite_kols": "inviteKols"
      "change @ui.fileInput": "import_csv"

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

    inviteKols: (e) ->
      e.preventDefault()
      this.ui.fileInput.trigger "click"

    onRender: () ->
      @ui.table.stupidtable()
