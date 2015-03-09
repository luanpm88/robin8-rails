Robin.Collections.SelectedMediaLists = Backbone.Collection.extend({
  model: Robin.Models.MediaList,
  initialize: function(){
    this.on('remove', this.removeContactsChilds, this);
    this.on('add', this.addContactsChilds, this);
  },
  removeContactsChilds: function(model, collection, options){
    _(model.get('contacts')).each(function(contact){
      var model = options.pitchContactsCollection.findWhere({
        contact_id: contact.id,
        origin: 'media_list'
      });
      options.pitchContactsCollection.remove(model);
    });
  },
  addContactsChilds: function(model, collection, options){
    _(model.get('contacts')).each(function(contact){
      var current_model = options.pitchContactsCollection.findWhere({
        contact_id: contact.id,
        origin: 'media_list'
      });
      
      if (current_model == null){
        var model = new Robin.Models.Contact({
          contact_id: contact.id,
          origin: 'media_list',
          first_name: contact.first_name,
          last_name: contact.last_name,
          email: contact.email,
          outlet: "Media List"
        });
        options.pitchContactsCollection.add(model);
      }
    });
  }
});
