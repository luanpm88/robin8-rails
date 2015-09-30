Robin.Models.CampaignInvitation = Backbone.Model.extend
  urlRoot: '/campaign_invite'

  decline: ()->
    this.set
      status: "D"
    this.save()

  accept: ()->
    this.set
      status: "A"
    this.save()

  negotiate: ()->
    this.set
      status: "N"
    this.save()

