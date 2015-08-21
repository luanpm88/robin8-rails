Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.Campaigns = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/campaigns'

    ui:
      table: "#campaigns-table"
      add: "#add-budget-confirm"
      form: "#add-budget-form"

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        date.toLocaleFormat '%d-%b-%Y'
      timestamp: (d) ->
        date = new Date d
        date.getTime()

    events:
      "click #add_budget": "openModalDialog"
      "click #add_budget_icon": "openModalDialog"
      "click @ui.add": "add"

    collectionEvents:
      "reset add remove change": "render"

    onRender: () ->
      @ui.table.DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 10
        autoWidth: false
        columnDefs: [sortable: false, targets: ["no-sort"]]

      @ui.form.ready(_.bind @initFormValidation, @)

    openModalDialog: (e) ->
      $("#add-budget-modal input").val("")
      @ui.form.data('formValidation').resetForm()
      campaignId = e.target.attributes["campaign"].value
      $("#campaign-input").val(campaignId)
      @$el.find('#add-budget-modal').modal keyboard: false

    add: () ->
      @ui.form.data('formValidation').validate()
      if @ui.form.data('formValidation').isValid()
        @ui.form.data('formValidation').resetForm()
        data = _.reduce $("#add-budget-form").serializeArray(), ((m, i) -> m[i.name] = i.value; m), {}
        $.post "/campaign/add_budget/", data, (data) =>
          if data.status == "ok"
            $("#add-budget-modal").modal("hide")
            $('#add-budget-modal').on 'hidden.bs.modal', () =>
              @collection.fetch()
          else
            $.growl {message: data.status}, {type: 'danger'}

    initFormValidation: () ->
      @ui.form.formValidation({
        framework: 'bootstrap',
        excluded: [':disabled', ':hidden'],
        icon: {
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
          budget: {
            validators: {
              notEmpty: {
                message: polyglot.t('smart_campaign.budget_required')
              },
              digits: {
                message: polyglot.t('smart_campaign.budget_must_number')
              }
            }
          }
        }
      })
