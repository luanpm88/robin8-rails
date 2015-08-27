Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _) {
  Robin.Collections.EmailTargetsCollection = Backbone.Collection.extend({
    model: Robin.Models.Contact
  });

  Robin.Collections.TwitterTargetsCollection = Backbone.Collection.extend({
    model: Robin.Models.Contact
  });

  ReleasesBlast.EmailTargetItemView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/email-item-view',
    tagName: 'tr',
    ui: {
      deleteButton: 'a'
    },
    events: {
      'click @ui.deleteButton': 'deleteButtonClicked'
    },
    deleteButtonClicked: function(e){
      e.preventDefault();

      this.deleteTarget();
    },
    deleteTarget: function() {
      this.triggerMethod('email:target:removed', this.model);
      this.options.parentCollection.remove(this.model);
    }
  });

  ReleasesBlast.EmailTargetsView = Backbone.Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/email-collection-view',
    collection: Robin.Collections.EmailTargetsCollection,
    childView: ReleasesBlast.EmailTargetItemView,
    model: Robin.Models.MediaList,
    childViewContainer: "tbody",
    className: 'well',
    childViewOptions: function(){
      return {
        parentCollection: this.collection
      };
    },
    ui: {
      count: 'span.badge-success',
      mediaListNameInput: 'input',
      saveListButton: 'button'
    },
    collectionEvents: {
      "remove": "modelRemoved",
      "add": "modelAdded"
    },
    events: {
      "change @ui.mediaListNameInput": "mediaListNameInputChanged",
      "click @ui.saveListButton": "saveListButtonClicked"
    },
    modelRemoved: function(model) {
      this.ui.count.text(this.collection.length);
      this.model.get('media_contacts').remove(model);
    },
    modelAdded: function(model){
      this.model.get('media_contacts').add(model);
    },
    templateHelpers: function() {
      return {
        size: this.collection.length
      }
    },
    initialize: function(options){
      this.model.get('media_contacts').add(this.collection.models);
    },
    mediaListNameInputChanged: function(e){
      this.model.set('name', this.ui.mediaListNameInput.val());
    },
    errorFields: {
      "name": "List name",
      "contacts": "Contacts"
    },
    saveListButtonClicked: function(e){
      var self = this;
      this.model.save({}, {
        success: function(model, response, options){
          self.model.clear({silent: true});
          self.model.get('media_contacts').add(self.collection.models);
          self.ui.mediaListNameInput.trigger('change');

          $.growl({message: polyglot.t("smart_release.pitch_step.targets_table.success_uploaded_list")
          },{
            type: 'success'
          });
        },
        error: function(model, response, options){
          _(response.responseJSON).each(function(val, key){
            $.growl({message: self.errorFields[key] + ' ' + val[0]
            },{
              type: 'danger'
            });
          });
        }
      });
    }
  });

  ReleasesBlast.TwitterTargetItemView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/twitter-item-view',
    tagName: 'tr',
    ui: {
      deleteButton: 'a'
    },
    events: {
      'click @ui.deleteButton': 'deleteButtonClicked'
    },
    deleteButtonClicked: function(e){
      e.preventDefault();

      this.deleteTarget();
    },
    deleteTarget: function() {
      this.triggerMethod('twitter:target:removed', this.model);
      this.options.parentCollection.remove(this.model);
    }
  });

  ReleasesBlast.TwitterTargetsView = Backbone.Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/twitter-collection-view',
    collection: Robin.Collections.TwitterTargetsCollection,
    childView: ReleasesBlast.TwitterTargetItemView,
    childViewContainer: "tbody",
    className: 'well',
    childViewOptions: function(){
      return {
        parentCollection: this.collection
      };
    },
    ui: {
      count: 'span.badge-success'
    },
    templateHelpers: function () {
      return {
        size: this.collection.length
      }
    },
    modelRemoved: function() {
      this.ui.count.text(this.collection.length);
    },
    collectionEvents: {
      "remove": "modelRemoved"
    }
  });

  ReleasesBlast.EmailPitchView = Backbone.Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/email-pitch-view',
    className: 'panel panel-primary',
    ui: {
      mergeTag: 'label.label a',
      textarea: '#email-pitch-textarea',
      summarySlider: '#summary-slider',
      summarySliderAmount: '#summary-slider-amount',
      subjectLineInput: '[name=email_subject]',
      emailAddressInput: '[name=email_address]',
      previewButton: '#pitch-text-preview',
      sendTestEmailButton: '#send-test-email-btn'
    },

    events: {
      'click @ui.mergeTag': 'addMergeTag',
      'change @ui.subjectLineInput': 'subjectLineInputChanged',
      'change @ui.emailAddressInput': 'emailAddressInputChanged',
      'click @ui.sendTestEmailButton': 'sendTestEmailButtonClicked'
    },

    addMergeTag: function(e) {
      e.preventDefault();

      this.editor.composer.commands.exec("insertHTML", '@[' + e.target.textContent + '] ')
      this.insertRenderedText();
    },
    initialize: function(options){
      this.releaseModel = options.releaseModel;
      this.draftPitchModel = options.draftPitchModel;
    },
    serializeData: function() {
      return {
        mergeTags: [
          polyglot.t("smart_release.pitch_step.email_panel.merge_tags.first_name"),
          polyglot.t("smart_release.pitch_step.email_panel.merge_tags.last_name"),
          polyglot.t("smart_release.pitch_step.email_panel.merge_tags.summary"),
          polyglot.t("smart_release.pitch_step.email_panel.merge_tags.outlet"),
          polyglot.t("smart_release.pitch_step.email_panel.merge_tags.link"),
          polyglot.t("smart_release.pitch_step.email_panel.merge_tags.title"),
          polyglot.t("smart_release.pitch_step.email_panel.merge_tags.text")
        ],
        pitch: this.model.toJSON()
      }
    },
    onRender: function() {
      var self = this;
      this.initWysihtml5();
      this.ui.summarySlider.slider({
        value: self.draftPitchModel.get('summary_length'),
        min: 1,
        max: 10,
        step: 1,
        slide: function(event, ui) {
          self.ui.summarySliderAmount.text(ui.value + " " + polyglot.t("smart_release.pitch_step.email_panel.sentences"));
          self.model.set('summary_length', parseInt(ui.value));
        }
      });
      this.ui.summarySliderAmount.text(this.ui.summarySlider.slider("value") + " " + polyglot.t("smart_release.pitch_step.email_panel.sentences"));
    },
    initWysihtml5: function(){
      var self = this;

      this.ui.textarea.wysihtml5({
        "image": false,
        "video": false,
        "color": false,
        'html': false,
        "blockquote": true,
        "table": false,
        "link": true,
        "textAlign": false,
        "autoLink": true
      });

      var wysihtml5Editor = this.ui.textarea.data("wysihtml5").editor;
      wysihtml5Editor.on("load", function() {
        self.editor = self.ui.textarea.data('wysihtml5').editor;
        var emailPitchTextChanged = function(){
          self.model.set('email_pitch', self.editor.getValue());
          self.insertRenderedText();
        };

        self.editor.on('change', emailPitchTextChanged);
        self.editor.on('blur', emailPitchTextChanged);

        self.insertRenderedText();
      });
    },
    sendTestEmailButtonClicked: function(e){
      if (this.draftPitchModel.get('is_deleted')){
        $.growl({message: "It's no longer possible to send test emails after pitch has been sent."
        },{
          type: 'danger'
        });
      } else {
        this.showTestEmailModal();
      }
    },
    showTestEmailModal: function(e){
      var testEmailModel = new Robin.Models.TestEmail({
        draft_pitch_id: this.draftPitchModel.id
      });

      var testEmailView = new ReleasesBlast.TestEmailView({
        model: testEmailModel,
        draftPitchModel: this.draftPitchModel
      });

      Robin.modal.show(testEmailView);
    },
    subjectLineInputChanged: function(e){
      this.model.set('email_subject', this.ui.subjectLineInput.val());
    },
    emailAddressInputChanged: function(e){
      this.model.set('email_address', this.ui.emailAddressInput.val());
    },
    insertRenderedText: function(){
      var text = this.editor.getValue();
      text = this.renderPitchText(text);
      this.editor.setValue(text);
    },
    renderPitchText: function(text){
      // Email pitch tags are:
      // ["@[First Name]", "@[Last Name]", "@[Summary]",
      // "@[Outlet]", "@[Link]", "@[Title]", "@[Text]"]
      var renderedText = text;

      var title = this.releaseModel.get('title');
      var html_text = this.releaseModel.get('text');

      var parser = document.createElement('a');
      parser.href = this.releaseModel.get('permalink');
      var newsRoomsName = parser.hostname.substring(0, parser.hostname.indexOf('.'));
      var link = this.releaseModel.get('permalink')+ '?utm_source=Robin8&utm_medium=email&utm_campaign='+newsRoomsName;
      link = '<a href="' + link +'">' + link + '</a>';
      var linkable_title = '<a href="' + this.releaseModel.get('permalink') +
        '?utm_source=Robin8&utm_medium=email&utm_campaign='+newsRoomsName+'">' + title + '</a>';
      var summariesArr = this.releaseModel.get('summaries')
        .slice(0, this.model.get('summary_length'));
      var summaries = _(summariesArr).reject(function(item){
        return s.isBlank(item);
      }).map(function(item){
        return '<li>' + item + '</li>'
      }).join(' ');
      summaries = '<ul>' + summaries + '</ul>';

      renderedText = renderedText.replace(/\@\[Title\]/g, linkable_title);
      renderedText = renderedText.replace(/\@\[Text\]/g, html_text);
      renderedText = renderedText.replace(/\@\[Link\]/g, link);
      renderedText = renderedText.replace(/\@\[Summary\]/g, summaries);

      this.model.set('email_pitch', renderedText);

      return renderedText;
    }
  });

  ReleasesBlast.TwitterPitchView = Backbone.Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/twitter-pitch-view',
    className: 'panel panel-primary',
    ui: {
      mergeTag: 'label.mergetag a',
      hashTag: 'label.hashtag',
      textarea: '#twitter-pitch-textarea',
      twitterPitchPreviewTextarea: '#twitter-pitch-preview',
    },
    events: {
      'click @ui.mergeTag': 'addMergeTag',
      'click @ui.hashTag': 'addHashTag',
      'change @ui.textarea': 'twitterPitchTextChanged',
      'keyup @ui.textarea': 'twitterPitchTextChanged'
    },
    addMergeTag: function(e) {
      e.preventDefault();

      this.ui.textarea.caret('@[' + e.target.textContent + '] ');
      this.ui.textarea.trigger('change');
      this.previewPitchText();
    },
    addHashTag: function(e) {
      e.preventDefault();

      this.ui.textarea.caret(e.target.textContent + ' ');
      this.ui.textarea.trigger('change');
      this.previewPitchText();
    },
    initialize: function(options){
      this.releaseModel = options.releaseModel;
      this.draftPitchModel = options.draftPitchModel;
    },
    onRender: function(){
      this.previewPitchText();
    },
    serializeData: function() {
      return {
        hashTags: this.releaseModel.get('hashtags'),
        mergeTags: ['Handle', 'Name', 'Random Greeting', 'Link'],
        pitch: this.draftPitchModel
      }
    },
    twitterPitchTextChanged: function(e){
      this.model.set("twitter_pitch", this.ui.textarea.val());

      this.previewPitchText();
    },
    previewPitchText: function(){
      var text = this.renderPitchText(this.ui.textarea.val());
      this.ui.twitterPitchPreviewTextarea.val(text);
    },
    renderPitchText: function(text){
      // Twitter pitch tags are:
      // [ "@[Handle]", "@[Name]", "@[Random Greeting]", "@[Link]" ]
      var renderedText = text;

      var link = this.releaseModel.get('permalink');

      renderedText = renderedText.replace(/\@\[Link\]/g, link);

      return renderedText;
    }
  });

  ReleasesBlast.TestEmailView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/test-email-view',
    ui: {
      emailsInput: '#test-pitch-emails-input',
      sendButton: '#send-test-btn'
    },
    events: {
      'click @ui.sendButton': 'sendButtonClicked'
    },
    initialize: function(options){
      this.draftPitchModel = options.draftPitchModel;
    },
    sendButtonClicked: function(e){
      e.preventDefault();

      this.ui.sendButton.prop('disabled', true);
      this.sendTestEmail();
    },
    errorFields: {
      "emails": "Email address",
      "email_pitch": "Email pitch",
      "email_address": "Pitch Email address",
      "email_subject": "Email subject"
    },
    sendTestEmail: function(){
      var self = this;
      this.model.set('emails', this.ui.emailsInput.val());

      this.model.save({ release_id: this.draftPitchModel.get('release_id')}, {
        success: function(model, response, options){
          Robin.modal.empty();
          $.growl({message: polyglot.t('smart_release.send_test.bon_voyage')
          },{
            type: 'success'
          });
        },
        error: function(model, response, options){
          self.ui.sendButton.prop('disabled', false);

          _(response.responseJSON).each(function(val, key){
            $.growl({message: self.errorFields[key] + ' ' + val[0]
            },{
              type: 'danger'
            });
          });
        }
      });
    }
  });

  ReleasesBlast.EmailMissing = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/email-missing',
    ui: {
      emailsButton: '#email',
      pitchButton: '#pitch'
    },
    events: {
      'click @ui.pitchButton': 'pitchButtonClicked',
      'click @ui.emailsButton': 'emailsButtonClicked'
    },
    initialize: function(options){
      this.parent = options.parent;
    },

    pitchButtonClicked: function(e){
      e.preventDefault();
      this.parent.savePitch();
      Robin.modal.empty();
    },
    emailsButtonClicked: function(e){
      e.preventDefault();
      this.parent.addEmail();
      Robin.modal.empty();
    }
  });

  ReleasesBlast.PitchTabView = Marionette.LayoutView.extend({
    template: 'modules/releases_blast/templates/pitch-tab/pitch-tab-layout',

    className: "tab-pane active",
    attributes: {
      "role": "tabpanel"
    },
    ui: {
      pitchButton: "#save-pitch",
    },
    childEvents: {
      'email:target:removed': function (childView, emailModel) {
        this.options.model.get('contacts').remove(emailModel);
      },
      'twitter:target:removed': function (childView, twitterModel) {
        this.options.model.get('contacts').remove(twitterModel);
      }
    },
    regions: {
      emailPitch:     '#email-pitch',
      emailTargets:   '#email-targets',
      twitterPitch:   '#twitter-pitch',
      twitterTargets: '#twitter-targets'
    },
    events: {
      "click @ui.pitchButton": "pitchButtonClicked",
    },
    modelEvents: {
      'remove:contacts': 'contactRemovedFromPitch'
    },
    initialize: function(options){
      this.releaseModel = options.releaseModel;
      this.draftPitchModel = options.draftPitchModel;
      this.model.on('change', this.updatePitchModel, this);
    },
    updatePitchModel: function(){
      var self = this;

      this.draftPitchModel.set({
        twitter_pitch: self.model.get('twitter_pitch'),
        email_pitch: self.model.get('email_pitch'),
        summary_length: self.model.get('summary_length'),
        email_address: self.model.get('email_address'),
        email_subject: self.model.get('email_subject')
      });

      clearInterval(this.timer);
      this.timer = setTimeout(function(){
        self.draftPitchModel.save();
      }, 1000);
    },
    contactRemovedFromPitch: function(){
      if (this.model.get('contacts').length === 0 )
        this.ui.pitchButton.prop('disabled', true);
    },
    addEmail: function()
    {
      console.log("add");
      this.$el.find('a[name="email-targets-list"]').click();
    },
    pitchButtonClicked: function(e){
      e.preventDefault();

      emails = this.model.get('contacts').getPressrContacts();
      console.log(this.model.get('contacts'));
      contacts = this.model.get('contacts');
      authorInputs = this.$el.find('input[name="author_email"]');
      _.each(authorInputs, function(input){
        email = input.value;
        id = input.getAttribute('data-pressr-id');

        _.each(emails, function(e) {
          if(e.get('author_id') == id)
          {
            e.set('email', email);
          }
        });

        _.each(contacts.models, function(contact) {
          console.log(contact)
          if (contact.get('origin') == 'pressr') {
            if (contact.get('author_id') == id) {
              contact.set('email', email);
              contact.set('need_approve', true);
            }
          }
        });
      });

      this.model.set('contacts',contacts);

      allEmails = true;
      _.each(emails, function(e) {
        if (!e.get('email')) {
          allEmails = false;
        }
      });

      if(!allEmails)
      {
        var emailMissing = new ReleasesBlast.EmailMissing({
          parent: this
        });
        Robin.modal.show(emailMissing);
      }
      else
      {
        this.savePitch();
      }
    },
    errorFields: {
      "email_address": "Email address",
      "email_subject": "Subject line",
      "twitter_pitch": "Twitter pitch text",
      "email_pitch": "Email pitch text",
      "user": "Your account"
    },
    savePitch: function(){
      var self = this;
      console.log(self.model);
      self.model.off("change", self.updatePitchModel);
      self.ui.pitchButton.prop('disabled', true);

      self.model.set('twitter_targets', self.getTwitterTargets());
      self.model.set('email_targets', self.getEmailTargets());

      self.model.save({}, {
        success: function(model, response, options){
          self.model.set('sent', true);
          self.draftPitchModel.set('is_deleted', true);
          self.draftPitchModel.destroy({
            data: { release_id: self.draftPitchModel.get('release_id') },
            processData: true
          });

          $.growl({message: polyglot.t("smart_release.pitch_step.targets_table.success_uploaded_list")
          },{
            type: 'success'
          });
        },
        error: function(model, response, options){
          self.model.on("change", self.updatePitchModel);
          self.ui.pitchButton.prop('disabled', false);

          _(response.responseJSON).each(function(val, key){
            $.growl({message: self.errorFields[key] + ' ' + val[0]
            },{
              type: 'danger'
            });
          });
        }
      });
    },
    getEmailTargets: function(){
      var emailContacts = this.model.get('contacts').getPressrContacts();
      var mediaListContacts = this.model.get('contacts').getMediaListContacts();

      if (emailContacts.concat(mediaListContacts).length > 0)
        return true;
      else
        return false
    },
    getTwitterTargets: function(){
      if (this.model.get('contacts').getTwtrlandContacts().length > 0)
        return true;
      else
        return false;
    }
  });
});
