Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.StartTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/start-tab'

    regions:
      content: "#campaign-content"
      characteristicsRegion: '#release-characteristics'
      analyticsRegion: '#analytics-campaign-text'

    ui:
      wysihtml5: 'textarea.wysihtml5'
      analyzeButton: '#analyze'
      form: "#campaign-form"

    events:
      "click @ui.save": "save"
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

    initialize: (options) ->
      @options = options
      @releaseCharacteristicsModel = new Robin.Models.ReleaseCharacteristics
      @model = if @options.model? then @options.model else new Robin.Models.Campaign()
      @modelBinder = new Backbone.ModelBinder()

    onRender: () ->
      insertLinkButton = @$el.find('#wyihtml5-insert-link').html()
      unLinkButton = @$el.find('#wyihtml5-unlink').html()
      extractButtonTemplate = @$el.find('#wyihtml5-extract-button').html()
      extractWordTemplate = @$el.find('#wyihtml5-word-button').html()
      extractDirectImageTemplate = @$el.find('#wyihtml5-direct-image-button').html()
      extractDirectVideoTemplate = @$el.find('#wyihtml5-direct-video-button').html()
      customTemplates =
        insert: (context) ->
          return insertLinkButton
        unlink: (context) ->
          return unLinkButton
        extract: (context) ->
          return extractButtonTemplate
        word: (context) ->
          return extractWordTemplate
        directImage: (context) ->
          return extractDirectImageTemplate
        directVideo: (context) ->
          return extractDirectVideoTemplate

      @ui.wysihtml5.wysihtml5(
        toolbar:
          insert: customTemplates.insert
          unlink: customTemplates.unlink
          extract: customTemplates.extract
          word: customTemplates.word
          directImage: customTemplates.directImage
          directVideo: customTemplates.directVideo
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
                "video": {
                    "check_attributes": {
                        "controls": "any",
                        "preload": "any",
                        "class": "any",
                        "width": "any",
                    }},
                "source": {
                    "check_attributes": {
                        "src": "any",
                    }},
                "blockquote": {},
                "u": 1,
                "img": {
                    "check_attributes": {
                        "width": "numbers",
                        "alt": "alt",
                        "src": "any",
                        "height": "numbers",
                        "title": "alt"
                    }
                },
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
      self = this
      @editor.on('load', () ->
        self.updateStats()
        if self.model.get('description')?
          analyze_button = document.getElementById("analyze")
          analyze_button.style.display = "none"
          child = new Show.StartAnalytics ({
            model: self.model
            reanalyze: true
            parent: self.options.parent
          })
          Robin.layouts.main.content.currentView.content.currentView.analyticsRegion.show child
        $('.wysihtml5-sandbox').contents().find('body').on('keyup keypress blur change focus', (e) ->
          self.updateStats()
        )
      )
      @characteristicsRegion.show(new Show.CharacteristicsView({
        model: @releaseCharacteristicsModel
      }))
      @modelBinder.bind(@model, @el)
      monthes = []
      monthesShort = []
      daysMin = []
      days = []
      for i in [0..11]
        monthes[i] = polyglot.t('date.monthes_full.m' + (i + 1))
        monthesShort[i] = polyglot.t('date.monthes_abbr.m' + (i + 1))
      for i in [0..6]
        days[i] = polyglot.t('date.days_full.d' + (i + 1))
        daysMin[i] = polyglot.t('date.datepicker_days.d' + (i + 1))
      @$el.find("#deadline").datepicker
        monthNames: monthes
        monthNamesShort: monthesShort
        dayNames: days
        dayNamesMin: daysMin
        nextText: polyglot.t('date.datepicker_next')
        prevText: polyglot.t('date.datepicker_prev')
        dateFormat: "D, d M y"
      if @model.get('deadline')?
        @$el.find("#deadline").datepicker("setDate", new Date(@model.get('deadline')))



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

    uploadDirectImage: (e) ->
      bookmark = @editor.composer.selection.getBookmark()
      uploadcare.openDialog(null, {
        tabs: 'file'
        multiple: false
        imagesOnly: true
        }).done((file) ->
            file.done((fileInfo) ->
              @editor.composer.selection.setBookmark(bookmark)
              @editor.focus()
              @editor.composer.commands.exec("insertImage", {src: fileInfo.originalUrl})
            )
        ).fail((error, fileInfo) ->
            console.log(error)
        )
      return false

    uploadUrlImage: (e) ->
      bookmark = @editor.composer.selection.getBookmark()
      url = prompt("Please paste you image's url")
      if url
        $.get( "/releases/img_url_exist?url=" + url, ( data ) ->
          if data
            window.setTimeout(() ->
              @editor.composer.selection.setBookmark(bookmark)
              @editor.focus()
              @editor.composer.commands.exec("insertImage", {src: url})
            , 200)
          else
            $.growl
              message: "Invalid url!"
              type: "info"
        )

    uploadDirectVideo: (e) ->
      bookmark = @editor.composer.selection.getBookmark()
      uploadcare.openDialog(null, {
        tabs: 'file'
        inputAcceptTypes: 'video/*'
        multiple: false
        }).done((file) ->
          file.done((fileInfo) ->
            @editor.composer.selection.setBookmark(bookmark)
            @editor.focus()
            @editor.composer.commands.exec("insertHTML", "<video width="+550+" class='video-js vjs-default-skin' controls='auto' preload='auto' data-setup='{}'> <source src='" + fileInfo.originalUrl + "'></video>")
          )
        ).fail((error, fileInfo) ->
          console.log(error);
        )
      return false;

    uploadUrlVideo: (e) ->
      bookmark = @editor.composer.selection.getBookmark()
      url = prompt("Please paste you video's url")
      if url
        window.setTimeout(() ->
          @editor.composer.selection.setBookmark(bookmark)
          @editor.focus()
          @editor.composer.commands.exec("insertVideo", url)
        , 200)

    extractURL: (e) ->
      url = prompt("Enter a link to grab the press release from:", "")
      editor = @editor
      if url
        $.ajax({
          url: 'textapi/extract'
          dataType: 'json'
          method: 'POST'
          data:
            url: url
          ,
          success: (response) ->
            if response.article.length == 0
              swal {
                title: "Invalid link!"
                text: "The link you've provided is invalid or the site it leads to contains no usable information"
                type: "error"
                showCancelButton: false
                confirmButtonClass: 'btn'
                confirmButtonText: 'ok'
              }
            else if (response.article.length > 60000)
              swal {
                title: "Provided release is too long"
                text:"Target page contains a text that exceeds the release length limit. The maximum is 60.000 characters (including spaces)"
                type: "error"
                showCancelButton: false
                confirmButtonClass: 'btn'
                confirmButtonText: 'ok'
              }
            else
              editor.setValue(response.article.replace(/(\r\n|\n\r|\r|\n)/g, '<br>'))
            if response.article.length > 0
              editor.setValue(response.article.replace(/(\r\n|\n\r|\r|\n)/g, '<br>'))
            else
              swal {
                title: "Invalid link!"
                text: "The link you've provided is invalid or the site it leads to contains no usable information"
                type: "error"
                showCancelButton: false
                confirmButtonClass: 'btn'
                confirmButtonText: 'ok'
              }
        })

    uploadWord: (changeEvent) ->
      self = this

      formData = new FormData()
      $input = $('#upload')

      if (_.last($input[0].files[0].name.split('.')) != 'docx')
        alert("Not supported file! Supported is *.docx")
        $input.replaceWith($input.val('').clone(true))
        return false

      formData.append('file', $input[0].files[0])

      $.ajax({
        url: "/releases/extract_from_word"
        data: formData
        cache: false
        contentType: false
        processData: false
        dataType: 'json'
        type: 'POST'
        complete: (response) ->
          $.ajax({
            url: 'textapi/extract'
            dataType: 'json'
            method: 'POST'
            data:
              html: response.responseText
            success: (text) ->
              self.parseResponseFromApi(text)
          })
      })

    parseResponseFromApi: (text) ->
      if (text != null)
        @editor.setValue( text.article.replace(/(\r\n|\n\r|\r|\n)/g, '</br>'))
      else
        alert("Something wrong with API")

    updateStats: _.debounce((e) ->
      html = @editor.getValue()
      el = document.getElementById("campaign-release-error")
      if html == ""
        el.style.display = "inline"
      else
        el.style.display = "none"
      div = document.createElement("div")
      div.innerHTML = html
      text = div.textContent || div.innerText || ""
      words = new Lexer().lex(text)
      taggedWords = new POSTagger().tag(words)
      numberOfNonSpaceCharacters = text.replace(/\W*/mg, '').length
      poses = _.chain(taggedWords).reject((w) ->
        return w[1].match(/^[,.]$/)
      ).countBy((w) -> return w[1].slice(0, 2) ).value()
      sentences = _(text.match(/[^.!?]+(\.!\?)?/g) || []).filter((s) ->
        return s.length > 5
      )
      @releaseCharacteristicsModel.set {
        numberOfNouns: poses.NN || 0
        numberOfAdverbs: poses.RB || 0
        numberOfAdjectives: poses.JJ || 0
        numberOfCharacters: text.length
        numberOfWords: words.length
        numberOfSentences: sentences.length
        numberOfNonSpaceCharacters: numberOfNonSpaceCharacters
        numberOfParagraphs: if words.length == 0 then 0 else text.split(/\n+/).length
      }
      @releaseCharacteristicsModel.set {
        readabilityScoreTitle: @releaseCharacteristicsModel.getReadabilityScoreTitle()
        readabilityScore: @releaseCharacteristicsModel.getReadabilityScore()
      }
    , 500)

    analyzeCampaignRelease: () ->
      data = _.reduce @ui.form.serializeArray(), ((m, i) -> m[i.name] = i.value; m), {}
      @ui.form.validator('validate')
      el = document.getElementById("campaign-release-error")
      if @editor.getValue() == ""
        el.style.display = "inline"
      form_valid = $(".form-group.has-error").length == 0
      if form_valid && @editor.getValue() != ""
        @model.set('description', data['description'])
        el.style.display = "none"
        analyze_button = document.getElementById("analyze")
        analyze_button.style.display = "none"
        analytics_view = new Show.StartAnalytics({
          model: @model
          parent: @options.parent
        })
        @showChildView 'analyticsRegion', analytics_view
