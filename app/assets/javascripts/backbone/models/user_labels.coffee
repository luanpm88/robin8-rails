Robin.Models.UserLabels = Backbone.Model.extend

  url: ()->
    return 'identities/labels/' + @id
