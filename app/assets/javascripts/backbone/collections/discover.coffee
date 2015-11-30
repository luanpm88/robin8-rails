Robin.Collections.Discovers = Backbone.Collection.extend
  model: Robin.Models.Discover

  initialize: (models, opts)->
    @labels = opts.labels
    @page = opts.page

  url: ()->
    return 'identities/discover/' + @labels + '?page=' + @page
