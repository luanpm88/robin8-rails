Robin.Models.PrivateKol = Backbone.Model.extend
  url: '/private_kol'
  toJSON: ->
    private_kol = _.clone this.attributes
    private_kol.full_name = this.fullName(private_kol.first_name, private_kol.last_name);
    private_kol: private_kol

  fullName: (firstName, lastName) ->
    if !s.isBlank(firstName) && !s.isBlank(lastName)
      firstName + ' ' + lastName
    else if !s.isBlank firstName
      firstName
    else if !s.isBlank lastName
      lastName
    else
      return "N/A"
