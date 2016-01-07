Robin.Collections.CampaignDiscovers = Backbone.Collection.extend
  model: Robin.Models.CampaignInvitation

  initialize: (models, opts)->
    @type = opts.type || 'upcoming'
    @limit = opts.limit || 3
    @offset = opts.offset || 0

  url: ()->
    return 'campaign_invite/interface/' + @type + '?limit=' + @limit + '&offset=' + @offset
