Robin.Collections.ManageableUsers = Backbone.Collection.extend({
  model: Robin.Models.ManageableUser,
  url: '/users/manageable_users/'
});