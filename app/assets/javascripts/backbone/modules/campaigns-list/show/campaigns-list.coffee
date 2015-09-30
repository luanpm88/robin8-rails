Robin.module 'CampaignsList.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.CampaignsListPage = Backbone.Marionette.LayoutView.extend
    template: 'modules/campaigns-list/show/templates/layout'

    regions:
      campaigns: '#campaigns'

  Show.CampaignsList = Backbone.Marionette.ItemView.extend
    template: 'modules/campaigns-list/show/templates/campaigns-list'

    ui:
      table: "#campaigns-table"

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        d = date.getDate()
        y = date.getFullYear()
        month = polyglot.t('date.monthes_abbr.m' + monthNum)
        "#{d}-#{month}-#{y}"
      timestamp: (d) ->
        date = new Date d
        date.getTime()

    events:
      "click #edit_campaign": "showEditCampaign"

    onRender: () ->
      @ui.table.DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 10
        autoWidth: false
        columnDefs: [sortable: false, targets: ["no-sort"]]
        language:
          paginate:
            previous: polyglot.t('smart_campaign.prev'),
            next: polyglot.t('smart_campaign.next')

    showEditCampaign: (e) ->
      id = e.target.attributes["campaign"].value
      campaign = new Robin.Models.Campaign { id: id }
      campaign.fetch
        success: (m, r, o) ->
          page = new Robin.SmartCampaign.Show.NewCampaign
            state: 'start'
            model: m
          Robin.layouts.main.content.show page

