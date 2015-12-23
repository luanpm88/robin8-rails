Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.Campaigns = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/campaigns'

    ui:
      table: "#campaigns-table"


    events:
      "click #copy_campaign": "showEditCampaign"

    templateHelpers:
      formatDate: (d) ->
        datetime = new Date(d);
        year = datetime.getFullYear();
        month = if datetime.getMonth() + 1 < 10 then "0" + (datetime.getMonth() + 1) else datetime.getMonth() + 1;
        date = if datetime.getDate() < 10 then "0" + datetime.getDate() else datetime.getDate();
        hour = if datetime.getHours() < 10 then "0" + datetime.getHours() else datetime.getHours();
        minute = if datetime.getMinutes() < 10 then "0" + datetime.getMinutes() else datetime.getMinutes();
        second = if datetime.getSeconds() < 10 then "0" + datetime.getSeconds() else datetime.getSeconds();
        return year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second;
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
        order: [[ 5, "desc" ]]
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
            isRenew: true
          Backbone.history.navigate("campaign/" + id);
          Robin.layouts.main.content.show page
