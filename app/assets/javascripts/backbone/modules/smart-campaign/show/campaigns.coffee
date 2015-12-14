Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.Campaigns = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/campaigns'

    ui:
      table: "#campaigns-table"

    events:
      "click #copy_campaign": "showEditCampaign"

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        d = date.getDate()
        y = date.getFullYear()
        month =  monthNum
        h = date.getHours();
        m = date.getMinutes();
        "#{y}-#{month}-#{d} #{h}:#{m}"
      timestamp: (d) ->
        date = new Date d
        date.getTime()

    collectionEvents:
      "reset add remove change": "render"

    onRender: () ->
      @ui.table.DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 10
        autoWidth: false
        columnDefs: [sortable: false, targets: [0]]
        order: [[ 6, "desc" ]]
        language:
          paginate:
            previous: polyglot.t('smart_campaign.prev'),
            next: polyglot.t('smart_campaign.next')

    showEditCampaign: (e) ->
      id = e.target.attributes["campaign"].value
      campaign = new Robin.Models.Campaign { id: id }
      console.log(campaign)
      campaign.fetch
        success: (m, r, o) ->
          page = new Robin.SmartCampaign.Show.NewCampaign
            state: 'start'
            model: m
          Backbone.history.navigate("campaign/" + id);
          Robin.layouts.main.content.show page
