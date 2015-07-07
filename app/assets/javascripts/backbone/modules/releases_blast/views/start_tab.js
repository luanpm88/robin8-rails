Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.StartTabView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/start_tab/show',
    collectionEvents: {
      "reset": "render"
    },
    ui: {
      releasesSelect: 'select',
      analyzeButton: '#analyze'
    },
    events: {
      'change @ui.releasesSelect': 'releasesSelectChanged',
      'click @ui.analyzeButton': 'analyzeButtonClicked'
    },
    serializeData: function(){
      return {
        "items": this.collection.models
      }
    },
    onRender: function(){
      var view = this;
      Robin.user.fetch({
        success: function() {
          if (Robin.user.get('can_create_release') != true) {
            view.$el.find("select.releases option#option-new-release").remove();
          }
        }
      });

      view.$el.find(".releases").select2({
        minimumResultsForSearch: Infinity
      });
      view.$el.find(".releases").prop('disabled', true);

      if (view.collection.length > 0) {
        view.$el.find(".releases").removeClass('loadinggif');
        view.$el.find(".releases").prop('disabled', false);
        if (Robin.releaseForBlast != undefined) {
          view.analyzeRelease(parseInt(Robin.releaseForBlast));
          Robin.releaseForBlast = undefined;
        }
      } else {
        view.$el.find(".releases").prop('disabled', false);
        view.$el.find(".releases").removeClass('loadinggif');
      }
    },
    releasesSelectChanged: function(e){
      if (Robin.user.get('can_create_smart_release') != true) {
        this.ui.analyzeButton.addClass('disabled-unavailable');
      } else {
        this.ui.analyzeButton.removeClass('disabled-unavailable');
      }
      if(this.ui.releasesSelect.val() == -2){
        this.openNewRelease();
      } else if (this.ui.releasesSelect.val() == -1){
        this.ui.analyzeButton.prop('disabled', true);
      } else {
        this.ui.analyzeButton.prop('disabled', false);
      }
    },
    openNewRelease: function(){
      Robin.newReleaseFromDashboard = true;
      Backbone.history.navigate('releases', {trigger: true});
    },
    analyzeButtonClicked: function(e){
      e.preventDefault();
      if (Robin.user.get('can_create_smart_release') != true) {
        $.growl({message: "You don't have available smart-releases!"},
          {
            type: 'info'
          });
      } else {        
        var selectValue = this.ui.releasesSelect.val();
        if ((selectValue != -1) || (selectValue != -2)){
          this.analyzeRelease(parseInt(selectValue));
        }
      }
    },
    errorFields: {
      "email_address": "Email address",
      "email_subject": "Subject line",
      "twitter_pitch": "Twitter pitch text",
      "email_pitch": "Email pitch text",
      "user": "Your account"
    },
    analyzeRelease: function(releaseId){
      var self = this;
      var the_release = this.collection.findWhere({id: releaseId});
      
      // Find or create DraftPitch
      var draftPitchesCollection = new Robin.Collections.DraftPitches({
        releaseId: the_release.id
      });
      
      draftPitchesCollection.fetchDraftPitch({success: function(collection){
        if (collection.length > 0){
          var model = collection.models[0];
          self.draftPitchModel.set(model.attributes);
          
          self.pitchModel.set({
            twitter_pitch: self.draftPitchModel.get('twitter_pitch'),
            email_pitch: self.draftPitchModel.get('email_pitch'),
            summary_length: self.draftPitchModel.get('summary_length'),
            email_address: self.draftPitchModel.get('email_address'),
            release_id: self.draftPitchModel.get('release_id'),
            email_subject: self.draftPitchModel.get('email_subject')
          });
          
          ReleasesBlast.controller.analysis({releaseModel: the_release});
        } else {
          self.draftPitchModel.set('release_id', the_release.id);
          
          var signature = [];
          signature.push('Best regards');
          
          // Full name
          var name = Robin.currentUser.get('name');
          if (!s.isBlank(name))
            signature.push(name + ','); // This is just for tracking name
          
          // Company name
          var company = Robin.currentUser.get('company');
          if (!s.isBlank(company))
            signature.push(company);
          
          // Email
          var email = Robin.currentUser.get('email');
          if (!s.isBlank(email))
            signature.push(email);
            
          var emailPitch = self.draftPitchModel.get('email_pitch');
          var signature_text = signature.join(",<br />").replace(',,', '');
          emailPitch = emailPitch.replace('@[Signature]', signature_text);
      
          self.draftPitchModel.set('email_pitch', emailPitch);
          self.draftPitchModel.set('email_address', Robin.currentUser.get('email'));
          
          self.pitchModel.set({
            twitter_pitch: self.draftPitchModel.get('twitter_pitch'),
            email_pitch: self.draftPitchModel.get('email_pitch'),
            summary_length: self.draftPitchModel.get('summary_length'),
            email_address: self.draftPitchModel.get('email_address'),
            release_id: self.draftPitchModel.get('release_id'),
            email_subject: self.draftPitchModel.get('email_subject')
          });
          
          self.draftPitchModel.save({}, {
            success: function(model, response, options){
              ReleasesBlast.controller.analysis({releaseModel: the_release});
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
      }});
    },
    initialize: function(options){
      var self = this;
      this.pitchModel = options.pitchModel;
      this.draftPitchModel = options.draftPitchModel;
      
      Robin.commands.setHandler("goToAnalysisTab", function(){
        if (self.ui.analyzeButton.prop('disabled') === false){
          var selectValue = self.ui.releasesSelect.val();
          if ((selectValue != -1) || (selectValue != -2)){
            self.analyzeRelease(parseInt(selectValue));
          }
        }
      });
      
      this.on("close", function(){ 
        Robin.commands.removeHandler("goToAnalysisTab");
      });
    }
  });
});
