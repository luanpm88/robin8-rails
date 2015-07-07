Robin.Collections.Campaigns = Backbone.Collection.extend
  model: Robin.Models.Campaign
  url: "/campaign"

  accepted: (params)->
    params['data'] = $.param({ status: "accepted"})
    this.fetch(params)

  declined: (params)->
    params['data'] = $.param({ status: "declined"})
    this.fetch(params)
