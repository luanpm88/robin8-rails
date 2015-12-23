Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.SmartCampaignPage = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/smart-campaign'

    regions:
      campaigns: '#campaigns'

    onShow: () ->
      $.ajax(
        type: "get"
        url: "/users/get_avail_amount" ,
        dataType: 'json')
        .done (data) ->
          $("div.balance").append(data.avail_amount)
