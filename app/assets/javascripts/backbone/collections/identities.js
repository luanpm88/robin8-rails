Robin.Collections.Identities = Backbone.Collection.extend({
  model: Robin.Models.Identity,
  url: '/kols/get_social_list'
});
