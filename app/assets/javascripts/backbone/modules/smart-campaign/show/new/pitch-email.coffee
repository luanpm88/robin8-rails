Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  NoChildrenView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-email-empty-targets'

  Show.EmailTargets = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-email-targets'
    emptyView: NoChildrenView

    ui:
      deleteButton: 'a.btn-danger'
      itemCount: '#item_count'

    events:
      'click @ui.deleteButton': 'deleteButtonClicked'

    templateHelpers:
      count: (items) ->
        c = 0
        $(items).each(() ->
          if this.invited == true
            c = c + 1
        )
        return c

    deleteButtonClicked: (e) ->
      e.preventDefault()
      target = $ e.currentTarget
      kol_id = target.data 'kol-id'
      @count = @count - 1
      @ui.itemCount.text(@count)
      target.parents('tr').remove()
      this.triggerMethod('email:target:removed', kol_id)

    onRender: ->
      c = 0
      $(@collection.models).each(() ->
        if this.get("invited") == true
          c = c + 1
      )
      @count = c


  Show.EmailPitch = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-email'
    className: 'panel panel-primary'
    ui:
      wysihtml5: 'textarea.wysihtml5'
      subjectLineInput: '[name=email_subject]',
      emailAddressInput: '[name=email_address]',
      form: '#email_pitch_form'
      mergeTag: 'label.label a'
      summarySlider: '#summary-slider',
      summarySliderAmount: '#summary-slider-amount',
      sendTestEmailButton: '#send-test-email-btn',
      textarea: '[name=email_text]'

    events:
      'click #direct-image-upload': 'uploadDirectImage'
      'click #url-image-upload': 'uploadUrlImage'
      'click #direct-video-upload': 'uploadDirectVideo'
      'click #url-video-upload': 'uploadUrlVideo'
      'click #insert_link': 'insertLink'
      'change #upload': 'uploadWord'
      'click #extract_url': 'extractURL'
      'click #unlink': 'unLink'
      'selectstart #insert_link': 'unselect'
      'mousedown #insert_link': 'unselect'
      'keydown #insert_link': 'unselect'
      'selectstart #direct-image-upload': 'unselect'
      'mousedown #direct-image-upload': 'unselect'
      'keydown #direct-image-upload': 'unselect'
      'selectstart #url-image-upload': 'unselect'
      'mousedown #url-image-upload': 'unselect'
      'keydown #url-image-upload': 'unselect'
      'selectstart #unlink': 'unselect'
      'mousedown #unlink': 'unselect'
      'keydown #unlink': 'unselect'
      'selectstart #direct-video-upload': 'unselect'
      'mousedown #direct-video-upload': 'unselect'
      'keydown #direct-video-upload': 'unselect'
      'selectstart #url-video-upload': 'unselect'
      'mousedown #url-video-upload': 'unselect'
      'keydown #url-video-upload': 'unselect'
      'click @ui.mergeTag': 'addMergeTag',
      'click @ui.sendTestEmailButton': 'sendTestEmailButtonClicked',
      'change @ui.subjectLineInput': 'subjectLineInputChanged',
      'change @ui.emailAddressInput': 'emailAddressInputChanged'

    onRender: () ->
      @model.set('summary_length', 5)
      self = this
      @ui.form.ready(self.initFormValidation())
      this.ui.summarySlider.slider({
        value: self.model.get('summary_length'),
        min: 1,
        max: 10,
        step: 1,
        slide: (event, ui) ->
          self.ui.summarySliderAmount.text(ui.value + " " + polyglot.t("smart_campaign.pitch_step.email_panel.sentences"))
          self.model.set('summary_length', parseInt(ui.value))
      })
      @ui.summarySliderAmount.text(@ui.summarySlider.slider("value") + " " + polyglot.t("smart_campaign.pitch_step.email_panel.sentences"))

      insertLinkButton = @$el.find('#wyihtml5-insert-link').html()
      unLinkButton = @$el.find('#wyihtml5-unlink').html()
      customTemplates =
        insert: (context) ->
          return insertLinkButton
        unlink: (context) ->
          return unLinkButton

      @ui.wysihtml5.wysihtml5(
        toolbar:
          insert: customTemplates.insert
          unlink: customTemplates.unlink,
        parserRules: {
          tags: {
            "b":  {},
            "i":  {},
            "br": {},
            "ol": {},
            "ul": {},
            "li": {},
            "h1": {},
            "h2": {},
            "h3": {},
            "h4": {},
            "h5": {},
            "h6": {},
            "source": {
              "check_attributes": {
                "src": "any",
              }},
            "blockquote": {},
            "u": 1,
            "a":  {
              check_attributes: {
                'href': "href",
                'target': 'any',
                'rel': 'alt'
              }
            },
            "iframe": {
              "check_attributes": {
                "src":"any",
                "width":"numbers",
                "height":"numbers"
              },
              "set_attributes": {
                "frameborder":"0"
              }
            },
            "p": 1,
            "span": 1,
            "div": 1,
            "table": 1,
            "tbody": 1,
            "thead": 1,
            "tfoot": 1,
            "tr": 1,
            "th": 1,
            "td": 1,
            "code": 1,
            "pre": 1,
            "style": 1
          }
        },
        'image': false,
        'video': false,
        'html': true,
        "blockquote": true,
        "table": false,
        "link": false,
        "textAlign": false
      )

      @editor = @ui.wysihtml5.data('wysihtml5').editor

      @editor.on("load", () ->
        self.editor = self.ui.textarea.data('wysihtml5').editor
        emailPitchTextChanged = () ->
          self.model.set('email_pitch', self.editor.getValue())
          self.insertRenderedText()
        self.editor.on('change', emailPitchTextChanged)
        self.editor.on('blur', emailPitchTextChanged)
        self.insertRenderedText()
      )


      @editor.focus()
      #@editor.css("padding") = "6 !important"

      @user = new Robin.Models.UserProfile(Robin.currentUser.attributes)
      this.ui.emailAddressInput.val(@user.get('email'))
      this.model.set('email_address', this.ui.emailAddressInput.val())
      this.editor.setValue(this.model.get('email_pitch'))

    addMergeTag: (e) ->
      e.preventDefault()
      this.editor.composer.commands.exec("insertHTML", '@[' + e.target.textContent + '] ')
      this.insertRenderedText()

    serializeData: () ->
      return {
        mergeTags: [
          'First Name', 'Last Name', 'Campaign Title', 'Summary', 'Text', 'User Name'
        ],
      pitch: this.model.toJSON()
      }

    insertRenderedText: () ->
      text = this.editor.getValue()
      text = this.renderPitchText(text)
      this.editor.setValue(text)

    renderPitchText: (text) ->
      # Email pitch tags are:
      # ["@[First Name]", "@[Last Name]", "@[Summary]",
      # "@[Outlet]", "@[Link]", "@[Title]", "@[Text]"]
      renderedText = text

      title = this.model.get('name')
      html_text = this.model.get('description')
      userName = Robin.currentUser.get('first_name') + ' ' + Robin.currentUser.get('last_name')
      #link = this.releaseModel.get('permalink')
      #link = '<a href="' + link + '">' + link + '</a>'
      #linkable_title = '<a href="' + this.releaseModel.get('permalink') + '">' + title + '</a>'
      summariesArr = this.model.get('summaries').slice(0, this.model.get('summary_length'))
      summaries = _(summariesArr).reject((item) ->
        return s.isBlank(item)
      ).map((item) ->
        return '<li>' + item + '</li>'
      ).join(' ')


      if summaries.length > 0
        summaries = '<ul>' + summaries + '</ul>'
        renderedText = renderedText.replace(/\@\[Summary\]/g, summaries)


      #kolLink = '<a href="' + window.location.origin + '/kols/new">register</a>'

      #renderedText = renderedText.replace(/\@\[KolReghref\]/g, kolLink)
      renderedText = renderedText.replace(/\@\[Campaign Title\]/g, title)
      renderedText = renderedText.replace(/\@\[Text\]/g, html_text)
      renderedText = renderedText.replace(/\@\[User Name\]/g, userName)


      this.model.set('email_pitch', renderedText)
      @ui.textarea.value = renderedText
      @ui.textarea.change()
      #@ui.form.data('formValidation').validate()

      return renderedText

    sendTestEmailButtonClicked: (e) ->
      @ui.form.data('formValidation').validate()
      if @ui.form.data('formValidation').isValid()
        testEmailView = new Show.TestEmail
          model: @model
        Robin.modal.show(testEmailView)

    subjectLineInputChanged: (e) ->
      this.model.set('email_subject', this.ui.subjectLineInput.val())

    emailAddressInputChanged: (e) ->
      this.model.set('email_address', this.ui.emailAddressInput.val())


    initFormValidation: () ->
      @ui.form.formValidation({
        framework: 'bootstrap',
        icon: {
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
        },
        excluded: ':disabled',
        fields: {
          email_subject: {
            trigger: 'blur'
            validators: {
              notEmpty: {
                message: 'The subject is required'
              }
            }
          },
          email_address: {
            trigger: 'blur'
            validators: {
              notEmpty: {
                message: 'The email adress is required'
              }
            }
          },
          email_text: {
            trigger: 'change'
            validators: {
              notEmpty: {
                message: 'The email text is required'
              }
            }
          }
        }
      })

    insertLink: (e) ->
      bookmark = @editor.composer.selection.getBookmark()
      url = prompt("Please paste your url")
      if url
        window.setTimeout(() ->
          @editor.composer.selection.setBookmark(bookmark)
          @editor.focus()
          if (!/^(f|ht)tps?:\/\//i.test(url) && !/^mailto?:/i.test(url))
            url = "http://" + url
          @editor.composer.commands.exec("createLink", {href: url, target: '_blank'})
        , 200)

    unLink: (e) ->
      bookmark = @editor.composer.selection.getBookmark()
      window.setTimeout(() ->
        @editor.composer.selection.setBookmark(bookmark)
        @editor.focus()
        @editor.composer.commands.exec("unlink")
      , 200)
