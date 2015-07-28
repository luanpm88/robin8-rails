Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Robin.Collections.EmailTargetsCollection = Backbone.Collection.extend
    model: Robin.Models.Contact

  Show.EmailTargets = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-email-targets'


  Show.WeChatTargets = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-wechat-targets'

  Show.WeiboTargets = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-weibo-targets'

  Show.EmailPitch = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-email'

    ui:
      wysihtml5: 'textarea.wysihtml5'
      subjectLineInput: '[name=email_subject]',
      emailAddressInput: '[name=email_address]',
      form: '#email_pitch_form'

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
      'click @ui.analyzeButton': 'analyzeCampaignRelease'

    onRender: () ->
      @$el.find("#deadline").datepicker
        dateFormat: "D, d M y"

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
          unlink: customTemplates.unlink
        ,
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
      @editor.focus()

      this.ui.emailAddressInput.val(this.model.get('email'))
      this.editor.setValue(this.model.get('emailpitch'))

      that = this;
      @ui.form.ready(that.initFormValidation())

    initFormValidation: () ->
      @ui.form.formValidation({
        framework: 'bootstrap',
        icon: {
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
        },
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
          description: {
            trigger: 'blur'
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

  Show.WeChatPitch = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-wechat'

    ui:
      textarea: '#wechat_pitch_textarea',
      textareaPreview: '#wechat_pitch_preview'
      form: '#wechat_pitch_form'

    events:
      'change @ui.textarea': 'wechatPitchTextChanged',
      'keyup @ui.textarea': 'wechatPitchTextChanged'

    onRender: (opts) ->
      this.ui.textarea.val(this.model.get('wechatpitch'))
      this.ui.textareaPreview.val(this.model.get('wechatpitch'))
      that = this;
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
          wechat_pitch_textarea: {
            trigger: 'blur'
            validators: {
              notEmpty: {
                message: 'The pitch text is required'
              }
            }
          }
        }
      })

    wechatPitchTextChanged: (e) ->
      @ui.form.data('formValidation').validate()
      if @ui.form.data('formValidation').isValid()
        this.model.set("wechatpitch", this.ui.textarea.val())



  Show.WeiboPitch = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/pitch/pitch-weibo'

    ui:
      textarea: '#weibo_pitch_textarea',
      textareaPreview: '#weibo_pitch_preview'
      form: '#weibo_pitch_form'

    events:
      'change @ui.textarea': 'weiboPitchTextChanged',
      'keyup @ui.textarea': 'weiboPitchTextChanged'

    onRender: (opts) ->
      this.ui.textarea.val(this.model.get('weibopitch'))
      this.ui.textareaPreview.val(this.model.get('weibopitch'))
      that = this;
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
          weibo_pitch_textarea: {
            trigger: 'blur'
            validators: {
              notEmpty: {
                message: 'The pitch text is required'
              }
            }
          }
        }
      })

    weiboPitchTextChanged: (e) ->
      @ui.form.data('formValidation').validate()
      if @ui.form.data('formValidation').isValid()
        this.model.set("weibopitch", this.ui.textarea.val())


  Show.PitchTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/pitch-tab'

    regions:
      emailPitch: '#email-pitch',
      emailTargets: '#email-targets',
      wechatPitch:  '#wechat-pitch',
      wechatTargets: '#wechat-targets',
      weiboPitch: '#weibo-pitch',
      weiboTargets: '#weibo-targets'

    ui:
      wysihtml5: 'textarea.wysihtml5'
      pitchButton: "#save-pitch"

    events:
      "click @ui.pitchButton": "pitchButtonClicked"

    #modelEvents:
    #  'remove:contacts': 'contactRemovedFromPitch'

    onRender: (opts) ->

      data = {
          name: "bla",
          description: "bla-bla",
          email:"dyerygin@redwerk.com",
          emailpitch:"Hey @[Handle] here's a press release you might find interesting: @[Link]",
          wechatpitch:"Hey @[Handle] here's a press release you might find interesting: @[Link]",
          weibopitch:"Hey @[Handle] here's a press release you might find interesting: @[Link]",
          contacts: {
            weibo: [{username:"name1"}, {username:"name2"}],
            influencers: [{name:"name1", email:"xuy@xuy.com", id:"666"}],
            wechat: [{name: "xuy", id: "dfassdfsfsadf"}]
          }
      }

      @model  = new Backbone.Model(data)


      influencers = new Backbone.Collection({name:"name", email:"xuy@xuy.com", id:"666"})
      wechat = new Backbone.Collection({name:"xuy", id:"dfassdfsfsadf"})
      weibo = new Backbone.Collection([{name:"name1"}, {name:"name2"}])


      if influencers.length > 0
        emailTargetsView = new Show.EmailTargets
          collection: influencers
        @showChildView 'emailTargets', emailTargetsView
        emailView = new Show.EmailPitch
          model: @model
        @showChildView 'emailPitch', emailView

      if wechat.length > 0
        wechatTargetsView = new Show.WeChatTargets
          collection: wechat
        @showChildView 'wechatTargets', wechatTargetsView
        wechatView = new Show.WeChatPitch
          model: @model
        @showChildView 'wechatPitch', wechatView

      if weibo.length > 0
        weiboTargetsView = new Show.WeiboTargets
          collection: weibo
        @showChildView 'weiboTargets', weiboTargetsView
        weiboView = new Show.WeiboPitch
          model: @model
        @showChildView 'weiboPitch', weiboView
