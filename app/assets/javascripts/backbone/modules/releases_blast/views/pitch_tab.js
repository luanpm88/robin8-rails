Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _) {
  ReleasesBlast.EmailTargetModel = Backbone.Model.extend({});

  ReleasesBlast.TwitterTargetModel = Backbone.Model.extend({});

  ReleasesBlast.EmailTargetItemView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/email-item-view',
    tagName: 'tr',

    ui: {
      deleteButton: 'a.btn-danger'
    },

    events: {
      'click @ui.deleteButton': 'deleteTarget'
    },

    deleteTarget: function(e) {
      e.preventDefault();
      this.model.collection.remove(this.model);
    }
  });

  ReleasesBlast.EmailTargetsCollection = Backbone.Collection.extend({
    model: ReleasesBlast.EmailTargetModel
  });

  ReleasesBlast.EmailTargetsView = Backbone.Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/email-collection-view',
    childView: ReleasesBlast.EmailTargetItemView,
    childViewContainer: "tbody",

    templateHelpers: function() {
      return {
        size: this.collection.length
      }
    }
  });

  ReleasesBlast.TwitterTargetsCollection = Backbone.Collection.extend({
    model: ReleasesBlast.TwitterTargetModel
  });

  ReleasesBlast.TwitterTargetItemView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/twitter-item-view',
    tagName: 'tr',

    ui: {
      deleteButton: 'a.btn-danger'
    },

    events: {
      'click @ui.deleteButton': 'deleteTarget'
    },

    deleteTarget: function(e) {
      e.preventDefault();
      this.model.collection.remove(this.model);
    }
  });

  ReleasesBlast.TwitterTargetsView = Backbone.Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/twitter-collection-view',
    childView: ReleasesBlast.TwitterTargetItemView,
    childViewContainer: "tbody",

    templateHelpers: function () {
      return {
        size: this.collection.length
      }
    }
  });

  ReleasesBlast.EmailPitchView = Backbone.Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/email-pitch-view',

    ui: {
      mergeTag: 'label.label a',
      textarea: '#email-pitch-textarea'
    },

    events: {
      'click @ui.mergeTag': 'addMergeTag'
    },

    addMergeTag: function(e) {
      e.preventDefault();
      this.ui.textarea.caret('@[' + e.target.textContent + '] ');
    },

    serializeData: function() {
      return {
        mergeTags: [
          'First Name', 'Last Name', 'Summary', 'Related Articles',
          'Outlet', 'Link', 'Title'
        ]
      }
    }
  });

  ReleasesBlast.TwitterPitchView = Backbone.Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/twitter-pitch-view',

    hashTags: [],

    ui: {
      mergeTag: 'label.mergetag a',
      hashTag: 'label.hashtag',
      textarea: '#twitter-pitch-textarea'
    },

    events: {
      'click @ui.mergeTag': 'addMergeTag',
      'click @ui.hashTag': 'addHashTag'
    },

    addMergeTag: function(e) {
      e.preventDefault();
      this.ui.textarea.caret('@[' + e.target.textContent + '] ');
    },

    addHashTag: function(e) {
      e.preventDefault();
      this.ui.textarea.caret(e.target.textContent + ' ');
    },

    initialize: function(options) {
      if (options.hashTags) this.hashTags = options.hashTags;
    },

    serializeData: function() {
      return {
        hashTags: this.hashTags,
        mergeTags: ['Handle', 'Name', 'Random Greeting', 'Link']
      }
    }
  });

  ReleasesBlast.PitchTabView = Marionette.LayoutView.extend({
    template: 'modules/releases_blast/templates/pitch-tab',

    regions: {
      emailPitch:     '#email-pitch',
      emailTargets:   '#email-targets',
      twitterPitch:   '#twitter-pitch',
      twitterTargets: '#twitter-targets'
    },
  });
});
