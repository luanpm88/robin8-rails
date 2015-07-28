Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.TestEmail = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-testemail'

    ui:
      emailsInput: '#test-pitch-emails-input',
      senderInput: '#email-address-input',
      subjectInput: '#email-subject-input',
      bodyInput: '#email-pitch-input',
      sendButton: '#send-test-btn',
      form: "#send-test-email"

    events:
      'click @ui.sendButton': 'sendTestEmail'

    errorFields:
      "emails": "Email address",
      "email_pitch": "Email pitch",
      "email_address": "Pitch Email address",
      "email_subject": "Email subject"

    onRender: () ->
      console.log(@model.get('email_subject'))
      @ui.senderInput.val(@model.get('email_address'));
      @ui.subjectInput.val(@model.get('email_subject'));
      @ui.bodyInput.val(@model.get('email_pitch'));

    sendTestEmail: () ->
      data = _.reduce $("#send-test-email").serializeArray(), ((m, i) -> m[i.name] = i.value; m), {}

      $.post "/campaign/test_email/", data, (data) =>
        if data.status == "ok"
          Robin.modal.empty()
          $.growl({message: "Bon voyage, test email! Your test email is on its way to the test recipients."},{type: 'success'})
        else
          self.ui.sendButton.prop('disabled', false);
          $.growl {message: data.status}, {type: 'danger'}
