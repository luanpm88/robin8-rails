Robin.Models.SocialInfluence = Backbone.Model.extend

  url: ()->
    return 'identities/influence/' + @id
