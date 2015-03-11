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
      var current_model = this.pitchContactsCollection.findWhere({
        origin: 'twtrland',
        twitter_screen_name: this.model.get('screen_name')
      });
      
      if (current_model == null){
        var model = new Robin.Models.Contact({
          origin: 'twtrland',
          twitter_screen_name: this.model.get('screen_name'),
          first_name: this.model.get('firstName'),
          last_name: this.model.get('lastName'),
          outlet: "Twitter"
        });
        this.pitchContactsCollection.add(model);
      }
    },
    removeInfluencer: function(e) {
      this.toggleAddRemove(e);
      var model = this.pitchContactsCollection.findWhere({
        twitter_screen_name: this.model.get('screen_name'),
        origin: 'twtrland'
      });
      this.pitchContactsCollection.remove(model);
    },
    initialize: function(options) {
      this.pitchContactsCollection = options.pitchContactsCollection
    }
  });
});
