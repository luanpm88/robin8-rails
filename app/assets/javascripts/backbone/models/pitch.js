Robin.Collections.PitchContacts = Backbone.Collection.extend({
  model: Robin.Models.Contact,
  getPressrContacts: function(){
    return this.where({origin: 'pressr'});
  },
  getTwtrlandContacts: function(){
    return this.where({origin: 'twtrland'});
  },
  getMediaListContacts: function(){
    return this.where({origin: 'media_list'});
  }
});

Robin.Models.Pitch = Backbone.RelationalModel.extend({
  urlRoot: '/pitches',
  defaults: {
    email_pitch: "Hi @[First Name],\n\nHere's a press release you might find interesting:\n\n\"@[Title]\"\n\n@[Summary]\n\nPlease let me know your thoughts.\n\nRegards@[UserFirstName]",
    twitter_pitch: "Hey @[Name] here's a press release you might find interesting: @[Link]",
    summary_length: 5,
    email_address: null,
    email_subject: null
  },
  relations: [{
    type: Backbone.HasMany,
    key: 'contacts',
    relatedModel: Robin.Models.Contact,
    collectionType: Robin.Collections.PitchContacts
  }]
});
