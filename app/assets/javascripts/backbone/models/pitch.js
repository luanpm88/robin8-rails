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
    email_pitch: "Hi @[First Name],<br /><br />Here's a press release you might find interesting:<br /><br /> \"@[Title]\"<br /><br />@[Summary]<br /><br />Read more here: @[Link]<br /><br />Please let me know your thoughts.<br /><br />Regards@[UserFirstName]",
    twitter_pitch: "Hey @[Handle] here's a press release you might find interesting: @[Link]",
    summary_length: 5,
    email_address: null,
    email_subject: null,
    sent: false
  },
  relations: [{
    type: Backbone.HasMany,
    key: 'contacts',
    relatedModel: Robin.Models.Contact,
    collectionType: Robin.Collections.PitchContacts
  }]
});
