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
    email_pitch: "<%= polyglot.t('smart_release.pitch_step.email_panel.text_dear') %> @[First Name],<br /><br /><%= polyglot.t('smart_release.pitch_step.email_panel.text_here') %><br /><br />@[Signature]<br /><br /> <%= polyglot.t('smart_release.pitch_step.email_panel.text_text') %>:<br /><br />@[Title]<br /><br />@[Text]<br /><br /><%= polyglot.t('smart_release.pitch_step.email_panel.kols_register_href') %> @[KolReghref] <%= polyglot.t('smart_release.pitch_step.email_panel.kols_register_alias') %>",
    twitter_pitch: "Hey @[Handle] here's a press release you might find interesting: @[Link]",
    summary_length: 5,
    email_address: null,
    email_subject: null,
    sent: false,
  },
  relations: [{
    type: Backbone.HasMany,
    key: 'contacts',
    relatedModel: Robin.Models.Contact,
    collectionType: Robin.Collections.PitchContacts
  }]
});

Robin.Models.DraftPitch = Backbone.Model.extend({
  urlRoot: '/draft_pitches',
  defaults: {
    email_pitch: "<%= polyglot.t('smart_release.pitch_step.email_panel.text_dear') %> @[First Name],<br /><br /><%= polyglot.t('smart_release.pitch_step.email_panel.text_here') %><br /><br />@[Signature]<br /><br /> <%= polyglot.t('smart_release.pitch_step.email_panel.text_text') %>:<br /><br />@[Title]<br /><br />@[Text]<br /><br /><%= polyglot.t('smart_release.pitch_step.email_panel.kols_register_href') %> @[KolReghref] <%= polyglot.t('smart_release.pitch_step.email_panel.kols_register_alias') %>",
    twitter_pitch: "Hey @[Handle] here's a press release you might find interesting: @[Link]",
    summary_length: 5,
    email_address: null,
    email_subject: null,
  }
});

Robin.Collections.DraftPitches = Backbone.Collection.extend({
  url: '/draft_pitches',
  model: Robin.Models.DraftPitch,
  initialize: function(options) {
    if (options && options.releaseId)
      this.releaseId = options.releaseId;
  },
  fetchDraftPitch: function(options){
    var self = this;

    this.fetch({
      data: {
        release_id: self.releaseId
      },
      success: options.success
    });
  }
});
