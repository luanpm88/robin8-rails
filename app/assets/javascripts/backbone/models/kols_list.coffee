Robin.Models.KolsList = Backbone.Model.extend
  url: '/kols_lists'
  toJSON: ->
    kols_list: _.clone this.attributes
