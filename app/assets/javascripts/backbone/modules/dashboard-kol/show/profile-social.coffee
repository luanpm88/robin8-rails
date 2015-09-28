Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  login_template = _.template """
    <button class="btn social-login" id="<%= provider %>"><%= polyglot.t('dashboard_kol.profile_tab.login') %></button>
  """
  logged_in_template = _.template "Logged in as <%= name %>."

  flip = (f) -> (x, y) -> f y, x

  Show.ProfileSocialView = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/profile-social'

    events:
      "click .social-login": "social_login"

    templateHelpers:
      social_login: (provider, k) ->
        i = _(k.identities).find (x) -> x.provider == provider
        if typeof i == "undefined"
          login_template
            provider: provider
            polyglot: polyglot
        else
          logged_in_template
            name: i.name

    initialize: (opts) ->
      @model_binder = new Backbone.ModelBinder()

    onRender: ->
      @model_binder.bind @model, @el

    social_login: (e) ->
      e.preventDefault()
      provider = e.target.id
      url = "/users/auth/#{provider}"
      params = 'location=0,status=0,width=800,height=600'
      @connect_window = window.open url, "connect_window", params
      @interval = flip(setInterval) 500, =>
        if @connect_window.closed
          clearInterval @interval
          $.get "/kols/get_current_kol", (data) =>
            @model.set "identities", data.identities
            @render()

    serializeData: ->
      k: @model.toJSON()

