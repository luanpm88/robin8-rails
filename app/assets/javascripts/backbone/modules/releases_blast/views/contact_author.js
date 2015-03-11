Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.ContactModel = Backbone.Model.extend({
    urlRoot: "/share_by_email"
  });
  
  ReleasesBlast.ContactAuthorFormView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/contact-author/contact-form',
    model: Robin.Models.Author,
    className: "modal-dialog",
    events: {
      "click #send-btn": "sendBtnClicked"
    },
    ui: {
      summarizeSlider: "#slider",
      formMessage: "#form-message",
      subjectInput: "[name=subject]",
      emailInput: "[name=email]"
    },
    templateHelpers: function(){
      return {
        currentUser: Robin.currentUser
      };
    },
    initialize: function(options){
      this.releaseModel = options.releaseModel;
      this.contactModel = new ReleasesBlast.ContactModel();
    },
    onShow: function(){
      this.initSlider();
      this.renderMessageTextarea(5);
    },
    initSlider: function(){
      var self = this;
      this.ui.summarizeSlider.slider({
        min: 1,
        max: 10,
        range: "min",
        value: 5,
        slide: function (event, ui) {
          $("#number-of-sentences span").text(ui.value);
          self.renderMessageTextarea(parseInt(ui.value));
        }
      });
    },
    renderMessageTextarea: function(sentencesNumber){
      var messageTextarea = new ReleasesBlast.ContactAuthorFormMessageView({
        model: this.releaseModel,
        authorModel: this.model,
        sentencesNumber: sentencesNumber
      });
      this.ui.formMessage.html(messageTextarea.render().el);
    },
    sendBtnClicked: function(event){
      this.sendEmail();
    },
    errorFields: {
      "subject": "Subject",
      "body": "Message",
      "sender": "Your email",
      "reciever": "Email target"
    },
    sendEmail: function(){
      var self = this;
      this.contactModel.set({
        subject: this.ui.subjectInput.val(),
        body: this.ui.formMessage.find('textarea').val(),
        sender: this.ui.emailInput.val(),
        reciever: this.model.get('email')
      });
      
      this.contactModel.save({}, {
        success: function(model, response, options){
          Robin.modal.empty();
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
  
  ReleasesBlast.ContactAuthorFormMessageView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/contact-author/contact-form-message',
    model: Robin.Models.Release,
    tagName: 'textarea',
    className: 'form-control',
    attributes: {
      'rows': '7'
    },
    initialize: function(options){
      this.authorModel = options.authorModel;
      this.sentencesNumber = options.sentencesNumber;
    },
    serializeData: function(){
      return {
        "author": this.authorModel,
        "summary": this.summary(),
        "release": this.model,
        "currentUser": Robin.currentUser
      }
    },
    summary: function(){
      var sentences = _(this.model.get('summaries')).first(this.sentencesNumber);
      return _(sentences).map(function(sentence){ 
        return "- " + sentence
      }).join('\n');
    }
  });
});
