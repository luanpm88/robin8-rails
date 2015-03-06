Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.InfluencerView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/influencer-item',
    tagName: "tr",
    model: Robin.Models.Influencer,
    templateHelpers: function(){
      return {
        user: this.model
      }
    },
    events: {
      "click a.btn-danger":     "removeInfluencer",
      "click a.btn-success":    "addInfluencer"
    },
    toggleAddRemove: function(e) {
      e.preventDefault();
      var $e = $(e.target);
      if (e.target.nodeName === 'I') $e = $e.parent();
      var $other = $e.siblings();
      $e.attr('disabled', 'disabled');
      $other.removeAttr('disabled');
    },
    addInfluencer: function(e) {
      this.toggleAddRemove(e);
      var influencerId = this.model.get('screen_name');
      var model = new Robin.Models.Contact({
        id: 'twtrland_' + influencerId, 
        origin: 'twtrland',
        twitter_screen_name: influencerId,
        first_name: this.model.get('firstName'),
        last_name: this.model.get('lastName')
      });
      this.pitchContactsCollection.add(model);
    },
    removeInfluencer: function(e) {
      this.toggleAddRemove(e);
      this.pitchContactsCollection.remove('twtrland_' + this.model.get('screen_name'));
    },
    initialize: function(options) {
      this.pitchContactsCollection = options.pitchContactsCollection
    }
  });
});
