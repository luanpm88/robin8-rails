Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.ContactAuthorFormView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/contact-author/contact-form',
    model: Robin.Models.Author,
    className: "modal-dialog",
    events: {
      "click #send-btn": "sendBtnClicked"
    },
    ui: {
      summarizeSlider: "#slider",
      formMessage: "#form-message"
    },
    initialize: function(options){
      this.releaseModel = options.releaseModel;
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
      console.log("Send Button clicked!");
      this.sendEmail();
    },
    sendEmail: function(){
      console.log("Email sent!");
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
        "release": this.model
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
