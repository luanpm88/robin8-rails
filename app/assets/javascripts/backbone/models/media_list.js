Robin.Models.MediaList = Backbone.RelationalModel.extend({
  urlRoot: '/media_lists',
  defaults: {
    name: null
  },
  relations: [{
    type: Backbone.HasMany,
    key: 'media_contacts',
    relatedModel: Robin.Models.Contact,
    collectionType: Robin.Collections.EmailTargetsCollection
  }]
});
