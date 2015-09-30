Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.ScoreTab = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/score-tab'
    ui:
      form: '#score_form'
      next: '#next_to_campaign_btn'
      back: '#back_to_profile_btn'
      check_all: '#monetize_intrested_all'

    events:
      'click @ui.next': 'next'
      'click @ui.back': 'back'
      'click @ui.check_all': 'check_all'


    serializeData: () ->
      k: @model.toJSON()


    templateHelpers: () ->
      vs: (k) ->
        polyglot.t('dashboard_kol.score_tab.vsmonth', {per: "+#{k.stats.total_progress}%" })
      beat: (k) ->
        polyglot.t('dashboard_kol.score_tab.youbeat', {per: "#{k.stats.total_beat}%" })
      score: (k) ->
        k.stats.total

    save: (cb) ->
      @ui.form.data('formValidation').validate()
      if @ui.form.data('formValidation').isValid()
        @model_binder.copyViewValuesToModel()
        return if @model.toJSON() == @initial_attrs
        @model.monetize @model.attributes,
          success: (m, r) =>
            @initial_attrs = m.toJSON()
            App.currentKOL.set m.attributes
            $.growl "You profile was saved successfully", {type: "success"}
            cb()
          error: (m, r) =>
            console.log "Error saving KOL profile. Response is:"
            console.log r
            $.growl "Can't save profile info", {type: "danger"}

    next: ->
      @save =>
        @parent_view?.campaigns()

    back: ->
      @save =>
        @parent_view?.profile()

    initialize: (opts) ->
      @model = new Robin.Models.KolProfile App.currentKOL.attributes
      @initial_attrs = @model.toJSON()
      @model_binder = new Backbone.ModelBinder()
      @parent_view = opts.parent

    onRender: () ->
      @model_binder.bind @model, @el
      @$el.find('input[type=radio][checked]').prop('checked', 'checked')  # I❤js
      self = this
      @ui.form.validator()
      @ui.form.ready(self.init(self))

    init: (self) ->
      self.initFormValidation()

      self.initGauge(self, @model.attributes.stats.total)

      normalize = (max, v) ->
        if v == 0
          return 10  # avoid zero values so graph looks nicer for losers
        (v / max) * 100

      d = [
        [
          {axis: "Your influence channel", value: 100},
          {axis: "Social engagement", value: 100},
          {axis: "Content generation", value: 100},
          {axis: "Weibo fans", value: 100},
          {axis: "Validity of social profile", value: 100},
        ],
        [
          {axis: "Your influence channel", value: normalize(30, @model.attributes.stats.channels)},
          {axis: "Social engagement", value: normalize(10, @model.attributes.stats.engagement)},
          {axis: "Content generation", value: normalize(10, @model.attributes.stats.content)},
          {axis: "Weibo fans", value: normalize(10, @model.attributes.stats.fans)},
          {axis: "Validity of social profile", value: normalize(40, @model.attributes.stats.completeness)}
        ]
      ]
      mycfg = {
        w: 160,
        h: 150,
        maxValue: 100,
        levels: 0,
        ExtraWidthX: 190
      }


      el = self.$('#graph_score2')

      RadarChart.draw(el[0], d, mycfg)

    initGauge: (self, value) ->

      percent = (value / 100) * 40
      barWidth = 10
      numSections = 40
      sectionPerc = 1 / numSections / 1.5
      padRad = 0.05
      chartInset = 10
      totalPercent = .67

      el = d3.select(self.$('.chart-gauge')[0])

      margin = { top: 20, right: 20, bottom: 20, left: 20 }
      width = 160 - margin.left - margin.right
      height = width
      radius = Math.min(width, height) / 1.6

      percToDeg = (perc) ->
        perc * 360

      percToRad = (perc) ->
        degToRad percToDeg perc

      degToRad = (deg) ->
        deg * Math.PI / 180

      svg = el.append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom)

      chart = svg.append('g')
      .attr('transform', "translate(#{(width + margin.left) / 1.6}, #{(height + margin.top) / 1.6})")

      # build gauge bg
      for sectionIndx in [1..numSections-1]

        arcStartRad = percToRad totalPercent
        arcEndRad = arcStartRad + percToRad sectionPerc
        totalPercent += sectionPerc

        startPadRad = if sectionIndx is 0 then 0 else padRad / 2
        endPadRad = if sectionIndx is numSections then 0 else padRad / 2

        arc = d3.svg.arc()
        .outerRadius(radius - chartInset)
        .innerRadius(radius - chartInset - barWidth)
        .startAngle(arcStartRad + startPadRad)
        .endAngle(arcEndRad - endPadRad)
        if sectionIndx <= percent
          chart.append('path')
          .attr('class', "arc chart-color1")
          .attr('d', arc)
        else
          chart.append('path')
          .attr('class', "arc chart-color2")
          .attr('d', arc)

      chart.append('circle')
      .attr('class', 'chart-center')
      .attr('cx', 0)
      .attr('cy', 0)
      .attr('r', 50)

      chart.append('text')
      .attr('x', -23)
      .attr('y', 13)
      .attr('class', 'chart-text')
      .text(value)


    onShow: () ->
      if @model.attributes.avatar_url
        $("#avatar-image").attr('src', @model.attributes.avatar_url)

      viewObj = this
      this.widget = uploadcare.Widget('[role=uploadcare-uploader]').onUploadComplete( (info) ->
        $("#avatar-image").attr('src', info.cdnUrl)
        viewObj.model.set({avatar_url: info.cdnUrl})
      )

    check_all: () ->
      if @ui.check_all.checked
        console.log("checked")
      else
        console.log("unchecked")

    initFormValidation: () ->
      @ui.form.formValidation(
        framework: 'bootstrap'
        icon:
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
        fields:
          monetize_post:
            validators:
              digits:
                message: ''
          monetize_post_weibo:
            validators:
              digits:
                message: ''
          monetize_post_personal:
            validators:
              digits:
                message: ''
          monetize_post_public1st:
            validators:
              digits:
                message: ''
          monetize_post_public2nd:
            validators:
              digits:
                message: ''
          monetize_create:
            validators:
              digits:
                message: ''
          monetize_create_weibo:
            validators:
              digits:
                message: ''
          monetize_create_personal:
            validators:
              digits:
                message: ''
          monetize_create_public1st:
            validators:
              digits:
                message: ''
          monetize_create_public2nd:
            validators:
              digits:
                message: ''
          monetize_share:
            validators:
              digits:
                message: ''
          monetize_share_weibo:
            validators:
              digits:
                message: ''
          monetize_share_personal:
            validators:
              digits:
                message: ''
          monetize_share_public1st:
            validators:
              digits:
                message: ''
          monetize_share_public2nd:
            validators:
              digits:
                message: ''
          monetize_review:
            validators:
              digits:
                message: ''
          monetize_review_weibo:
            validators:
              digits:
                message: ''
          monetize_review_personal:
            validators:
              digits:
                message: ''
          monetize_review_public1st:
            validators:
              digits:
                message: ''
          monetize_review_public2nd:
            validators:
              digits:
                message: ''
          monetize_speech:
            validators:
              digits:
                message: ''
          monetize_speech_weibo:
            validators:
              digits:
                message: ''
          monetize_speech_personal:
            validators:
              digits:
                message: ''
          monetize_speech_public1st:
            validators:
              digits:
                message: ''
          monetize_speech_public2nd:
            validators:
              digits:
                message: ''
          monetize_event:
            validators:
              digits:
                message: ''
          monetize_focus:
            validators:
              digits:
                message: ''
          monetize_party:
            validators:
              digits:
                message: ''
          monetize_endorsements:
            validators:
              digits:
                message: ''
      ).on('err.field.fv', (e, data) ->
        data.element
        .data('fv.messages')
        .find('.help-block[data-fv-for="' + data.field + '"]').hide()
      )



