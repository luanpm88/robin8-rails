Robin.Collections.Campaigns = Backbone.Collection.extend
  model: Robin.Models.Campaign
  url: "/campaign"

  accepted: (params)->
    params['data'] = $.param({ status: "accepted"})
    this.fetch(params)

  declined: (params)->
    params['data'] = $.param({ status: "declined"})
    this.fetch(params)

  all: (params)->
    params['data'] = $.param({ status: "all"})
    this.fetch(params)

  industry: (params)->
    params['data'] = $.param({ status: "industry"})
    this.fetch(params)
