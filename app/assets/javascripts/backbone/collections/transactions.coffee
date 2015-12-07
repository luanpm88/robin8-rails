Robin.Collections.Transactions = Backbone.Collection.extend
  model: Robin.Models.Transaction
  url: "/transaction"

#  accepted: (params)->
#    params['data'] = $.param({ status: "accepted"})
#    this.fetch(params)
#
#  declined: (params)->
#    params['data'] = $.param({ status: "declined"})
#    this.fetch(params)
#
#  all: (params)->
#    params['data'] = $.param({ status: "all"})
#    this.fetch(params)
#
#  latest: (params)->
#    params['data'] = $.param({ status: "latest"})
#    this.fetch(params)
#
#  history: (params)->
#    params['data'] = $.param({ status: "history"})
#    this.fetch(params)
#
#  negotiating: (params)->
#    params['data'] = $.param({ status: "negotiating"})
#    this.fetch(params)
