Robin.Collections.Discovers = Backbone.Collection.extend
  model: Robin.Models.Discover

  initialize: (models, opts)->
    @labels = opts.labels

  url: ()->
    return 'identities/discover/' + @labels
