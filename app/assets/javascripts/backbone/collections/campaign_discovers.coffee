Robin.Collections.CampaignDiscovers = Backbone.Collection.extend
  modle: Robin.Models.Discover

  initialize: (models, opts)->
    @type = opts.type || 'upcoming'
    @limit = opts.limit || 3
    @offset = opts.offset || 0

  url: ()->
    return 'campaign_invite/' + @type + '?limit=' + @limit + '&offset=' + @offset
