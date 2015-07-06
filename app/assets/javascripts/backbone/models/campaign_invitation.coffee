Robin.Models.CampaignInvitation = Backbone.Model.extend

  decline: ()->
    this.set
      status: "D"
    this.save()

  accept: ()->
    this.set
      status: "A"
    this.save()

