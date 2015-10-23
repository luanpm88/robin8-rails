Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.TestEmail = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-testemail'

    ui:
      emailsInput: '#emails',
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
      @ui.senderInput.val(@model.get('email_address'))
      @ui.subjectInput.val(@model.get('email_subject'))
      @ui.bodyInput.val(@model.get('email_pitch'))
      that = this
      @ui.form.ready(that.initFormValidation())

    initFormValidation: () ->
      @ui.form.formValidation({
        framework: 'bootstrap',
        excluded: [':disabled', ':hidden'],
        icon: {
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
          emails: {
            trigger: 'blur'
            validators: {
              notEmpty: {
                message: 'The test email field text is required'
              }
            }
          }
        }
      })

    sendTestEmail: () ->
      @ui.form.data('formValidation').validate()
      if @ui.form.data('formValidation').isValid()
        data = _.reduce $("#send-test-email").serializeArray(), ((m, i) -> m[i.name] = i.value; m), {}

        $.post "/campaign/test_email/", data, (data) =>
          if data.status == "ok"
            Robin.modal.empty()
            $.growl({message: polyglot.t('smart_release.send_test.bon_voyage')},{type: 'success'})
          else
            self.ui.sendButton.prop('disabled', false);
            $.growl {message: data.status}, {type: 'danger'}
