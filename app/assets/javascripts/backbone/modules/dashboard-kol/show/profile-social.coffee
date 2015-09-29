Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  login_template = _.template """
    <div class="col-md-2 cell">
      <button class="btn form-control social-login" id="<%= provider %>"><%= polyglot.t('dashboard_kol.profile_tab.login') %></button>
    </div>
  """
  logged_in_template = _.template """
    <div class="col-md-3 cell">
      Logged in as <a href="<%= url %>"><%= name %></a>.&nbsp;&nbsp;
      <a href="#" id="<%= provider %>" class="disconnect"><i id="<%= provider %>" class="fa fa-trash"></i></a>
    </div>
  """

  flip = (f) -> (x, y) -> f y, x

  Show.ProfileSocialView = Backbone.Marionette.ItemView.extend
    template: 'modules/dashboard-kol/show/templates/profile-social'

    events:
      "click .social-login": "social_login"
      "click .disconnect": "social_unlogin"

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
            url: encodeURI(i.url)
            provider: provider

    initialize: (opts) ->
      @model_binder = new Backbone.ModelBinder()

    onRender: ->
      @model_binder.bind @model, @el

    social_unlogin: (e) ->
      e.preventDefault()
      provider = e.target.id
      i = _(@model.get('identities')).find (x) -> x.provider == provider
      $.ajax
        type: "DELETE"
        url: '/users/disconnect_social',
        dataType: 'json',
        data: { id: i.id }
        success: (data) =>
          identities = _.flatten data
          @model.set "identities", identities
          App.currentKOL.set "identities", identities
          @render()
        error: (xhr, textStatus) ->
          $.growl textStatus,
            type: "danger",

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
            App.currentKOL.set "identities", data.identities
            @render()

    serializeData: ->
      k: @model.toJSON()

