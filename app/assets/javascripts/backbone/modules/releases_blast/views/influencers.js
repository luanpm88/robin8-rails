Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.InfluencerView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/influencers/_influencer',
    tagName: "tr",
    ui: {
      tweetContactButton: '#tweet-contact-button'
    },
    events: {
      "click a.btn-danger":     "removeInfluencer",
      "click a.btn-success":    "addInfluencer",
      "click @ui.tweetContactButton": "tweetContactButtonClicked"
    },
    toggleAddRemove: function(e) {
      e.preventDefault();
      var $e = $(e.target);
      if (e.target.nodeName === 'I') $e = $e.parent();
      var $other = $e.siblings();
      $e.attr('disabled', 'disabled');
      $other.removeAttr('disabled');
    },
    tweetContactButtonClicked: function(e){
      e.preventDefault();
      
      console.log("tweet button clicked!");
      
      var view = Robin.layouts.main.saySomething.currentView;
      
      view.checkAbilityPosting();
      view.setCounter();
      e.stopPropagation();
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


  ReleasesBlast.SocialTargetsCompositeView = Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/influencers/influencers',
    childView: ReleasesBlast.InfluencerView,
    childViewContainer: "tbody",
    childViewOptions: function() {
      return this.options;
    },
    onRender: function () {
      this.initDataTable();
    },
    initDataTable: function(){
      this.$el.find('table').DataTable({
        "info": false,
        "searching": false,
        "lengthChange": false,
        "order": [[ 4, 'desc' ]],
        "pageLength": 5,
        "columns": [
          { "width": "30% !important" },
          null,
          null,
          null,
          null,
          null,
          null
        ]
      });
    }
  });
});
