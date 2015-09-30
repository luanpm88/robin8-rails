Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.ContactModel = Backbone.Model.extend
    urlRoot: "/share_by_email"


  Show.AuthorInspectLayout = Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/author-inspect-layout',
    regions:
      statsRegion: '#author-stats',
      recentStoriesRegion: '#author-recent-stories',
      relatedStoriesRegion: '#author-related-stories'
    className: 'modal-dialog'

  Show.ContactAuthorFormMessageView = Marionette.ItemView.extend

    template: 'modules/smart-campaign/show/templates/contact-author/contact-form-message',
    tagName: 'div',
    className: 'form-control',
    attributes:
      'contenteditable': 'true',
      'id': 'emailTextarea'

    initialize: (options) ->
      this.authorModel = options.authorModel
      this.sentencesNumber = options.sentencesNumber

    serializeData: () ->
      return {
        "author": this.authorModel,
        "summary": this.summary(),
        "release": this.model,
        "currentUser": Robin.currentUser,
        "kolSignUpUrl": window.location.protocol + window.location.host + "/kols/new"
      }

    summary: () ->
      sentences = _(this.model.get('summaries')).first(this.sentencesNumber)

      return _(sentences).reject((sentence) ->
        return s.isBlank(sentence)
      ).map((sentence) ->
        return "- " + sentence
      ).join('\n')

  Show.ContactAuthorFormView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/contact-author/contact-form',
    model: Robin.Models.Author,
    className: "modal-dialog",
    events:
      "click #send-btn": "sendBtnClicked"

    ui:
      summarizeSlider: "#slider",
      formMessage: "#form-message",
      subjectInput: "[name=subject]",
      emailInput: "[name=email]"

    templateHelpers: () ->
      return currentUser: Robin.currentUser


    initialize: (options) ->
      this.campaignModel = options.campaignModel
      this.contactModel = new Show.ContactModel()

    onShow: () ->
      this.initSlider()
      this.renderMessageTextarea(5)

    initSlider: () ->
      self = this;
      this.ui.summarizeSlider.slider({
        min: 1,
        max: 10,
        range: "min",
        value: 5,
        slide: (event, ui) ->
          $("#number-of-sentences span").text(ui.value)
          self.renderMessageTextarea(parseInt(ui.value))
      })

    renderMessageTextarea: (sentencesNumber) ->
      messageTextarea = new Show.ContactAuthorFormMessageView
        model: this.campaignModel,
        authorModel: this.model,
        sentencesNumber: sentencesNumber

      this.ui.formMessage.html(messageTextarea.render().el)

    sendBtnClicked: (event) ->
      this.sendEmail()

    errorFields:
      "subject": "Subject",
      "body": "Message",
      "sender": "Your email",
      "reciever": "Email target"

    sendEmail: () ->
      self = this
      this.contactModel.set({
        subject: this.ui.subjectInput.val(),
        body: this.ui.formMessage.find('textarea').val(),
        sender: this.ui.emailInput.val(),
        reciever: this.model.get('email')
      })

      this.contactModel.save {},
        success: (model, response, options) ->
          Robin.modal.empty()
        error: (model, response, options) ->
          $.growl(polyglot.t('smart_campaign.targets_step.weibo.contact_form.send_error'), {type: "danger"})

  Show.TargetWeibo = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/targets-tab-weibo'

    ui:
      table: "#weibo-table"
    events:
      'change input': 'selectWeibo'
      'click .inspect': 'openInspectModal'
      "click a.contact-author": "openContactAuthorModal"

    templateHelpers:
      weibo_id: ()->
        invited_weibo = @model.model.get("weibo")

        weibo_id = []
        if invited_weibo?
          $(invited_weibo).each(() ->
            weibo_id.push(this.pressr_id)
          )
        return weibo_id
      campaign_id: ()->
        @model.model.get("id")
      isPresent: (k, campaign_id, weibo_id) ->
        isShow = -1
        if (weibo_id.length >0) && campaign_id?
          isShow = weibo_id.indexOf(k.id)
        if isShow < 0 then true else false
      isChecked: (k, weibo_id) ->
        isChecked = -1
        invited_weibo = @model.model.get("weibo")
        weibo_id = []
        if invited_weibo?
          $(invited_weibo).each(() ->
            weibo_id.push(this.id)
          )
        if invited_weibo?
          isChecked = weibo_id.indexOf(k.id)
        if isChecked >=0 then true else false

    initialize: (model) ->
      @weibo = []
      @model = model

    serializeData: () ->
      weibo: @weibo,
      model: @model

    weibo_id: ()->
      invited_weibo = @model.model.get("weibo")
      weibo_id = []
      if invited_weibo?
        $(invited_weibo).each(() ->
          weibo_id.push(this.pressr_id)
        )
      return weibo_id

    campaign_id: ()->
      @model.model.get("id")

    invitedWeibo: () ->
      _.chain(@weibo)
      .filter (k) ->
        k.invited? and k.invited == true
      .pluck '[pressr_id]'
      .value()

    updateWeibo: (data) ->
      invited_weibo = @invitedWeibo()
      @weibo = _(data).map (k) ->
        if _.contains(invited_weibo, k.pressr_id)
          k.invited = true
          k
        else
          k

    selectWeibo: (e) ->
      target = $ e.currentTarget
      weibo_id = target.data 'weibo-id'
      weibo_status = target.is ':checked'
      weibo = _(@weibo).find (k) -> k.id == weibo_id
      weibo.invited = weibo_status
      influencers = []
      weibo_id = []
      if not @model.model.get("weibo")?
        @model.model.set("weibo",[])
      else
        influencers = @model.model.get("weibo")
      if influencers.length > 0
        $(influencers).each(() ->
          weibo_id.push(this.id)
        )

      index = weibo_id.indexOf(weibo.id)
      if index >= 0
        influencers.splice(index, 1)
        @model.model.set("weibo",influencers)
        $(document.getElementsByName(e.target.name)).each ->
          @checked = false
          @value = "NO"
      else
        influencers.push weibo
        @model.model.set("weibo",influencers)
        $(document.getElementsByName(e.target.name)).each ->
          @checked = true
          @value = "YES"

      @validate()
      if @model.model.get("weibo").length > 0
        document.getElementById("next-step").disabled = false
      else
        document.getElementById("next-step").disabled = true

    validate: () ->
      is_valid = _(@weibos).any (k) -> k.invited? and k.invited == true
      if not is_valid
        $(".weibo-header").addClass "error"
        $(".weibo-errors").show()
      else
        $(".weibo-header").removeClass "error"
        $(".weibo-errors").hide()
      is_valid

    onRender: () ->
      @ui.table.DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 25
        language:
          paginate:
            previous: polyglot.t('smart_campaign.prev'),
            next: polyglot.t('smart_campaign.next')
      if @model.model.get("weibo")?
        $(".weibo-header").removeClass "error"
        $(".weibo-errors").hide()

    setCampaignModel: (model) ->
      @campaignModel = model


    openInspectModal: (e) ->
      e.preventDefault()
      self = this

      target = $ e.currentTarget
      weibo_id = target.data 'weibo-id'
      weibo = _(@weibo).find (k) -> k.id == weibo_id
      weibo_model = new Robin.Models.Author {full_name: weibo.full_name, id: weibo.id }

      layout = new Show.AuthorInspectLayout
        model: weibo_model

      Robin.modal.show layout

      relatedStoriesCollection = new Robin.Collections.RelatedStories
        author_id: weibo_model.get('id'),
        releaseModel: @campaignModel

      layout.relatedStoriesRegion.show new Robin.Components.Loading.LoadingView
          className: 'stories-loading-container'

      relatedStoriesCollection.fetchWeiboStories({
        success: (collection, data, response) ->
          relatedStoriesView = new Show.StoriesList
            collection: collection
          layout.relatedStoriesRegion.show relatedStoriesView
      })

      recentStoriesCollection = new Robin.Collections.RecentStories
        author_id: weibo_model.get('id'),
        releaseModel: @campaignModel

      layout.recentStoriesRegion.show new Robin.Components.Loading.LoadingView
          className: 'stories-loading-container'

      recentStoriesCollection.fetchWeiboStories({
        success: (collection, data, response) ->
          recentStoriesView = new Show.StoriesList
            collection: collection
          layout.recentStoriesRegion.show recentStoriesView
        })

      authorStatsModel = new Robin.Models.AuthorWeiboStats { id: weibo_model.id }
      layout.statsRegion.show new Robin.Components.Loading.LoadingView

      authorStatsModel.fetch({
        success: (model, response, options) ->
          authorStatItemView = new Show.AuthorStatsView
            model: model,
            authorModel: weibo_model,
            campaignModel: self.campaignModel
          layout.statsRegion.show authorStatItemView
      })

    openContactAuthorModal: (e) ->
      e.preventDefault()

      target = $ e.currentTarget
      weibo_id = target.data 'weibo-id'
      weibo = _(@weibo).find (k) -> k.id == weibo_id
      weibo_model = new Robin.Models.Author {full_name: weibo.full_name, id: weibo.id, email: weibo.email }

      contactAuthorFormView = new Show.ContactAuthorFormView
        model: weibo_model,
        campaignModel: @campaignModel
      Robin.modal.show(contactAuthorFormView)

