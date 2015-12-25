Robin.module 'Transaction.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.Index = Backbone.Marionette.LayoutView.extend
    template: 'modules/transactions/templates/index'
    ui:
      form: "#profile-form"

    regions:
      social: ".social-content"

    events:
      'click @ui.next': 'save'

    initialize: (opts) ->
      @target = target
      @model = new Robin.Models.KolProfile App.currentKOL.attributes
      @model_binder = new Backbone.ModelBinder()
      @initial_attrs = @model.toJSON()
      @parent_view = opts.parent

    onRender: ->
      @model_binder.bind @model, @el
      $("#password").val("")
      $("#current_password").val("")
      $("#password_confirmation").val("")
      _.defer =>
        @initAddSocialAccount()
      @initSocialList()
      @initDatepicker()
      @$el.find('input[type=radio][checked]').prop('checked', 'checked')
