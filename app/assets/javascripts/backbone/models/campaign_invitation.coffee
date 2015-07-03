Robin.Models.CampaignInvitation = Backbone.Model.extend

  initialize: () ->
    @set 'deadline_date', @getDeadline()
    @set 'invite_date', @getInviteDate()

  decline: ()->
    this.set
      status: "D"
    this.save()

  accept: ()->
    this.set
      status: "A"
    this.save()

  getDeadline: () ->
    (new Date(@get('campaign').deadline)).toString()

  getInviteDate: () ->
    (new Date(@get('created_at'))).toString()
