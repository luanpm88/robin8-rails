Robin.Models.Contact = Backbone.RelationalModel.extend({
  toJSON: function() {
    var contact = _.clone( this.attributes );
    contact.full_name = this.fullName(contact.first_name, contact.last_name);
    
    return contact;
  },
  fullName: function(firstName, lastName){
    if (!s.isBlank(firstName) && !s.isBlank(lastName))
      return firstName + ' ' + lastName;
    else if (!s.isBlank(firstName))
      return firstName;
    else if (!s.isBlank(lastName))
      return lastName;
    else
      return "N/A";
  }
});
