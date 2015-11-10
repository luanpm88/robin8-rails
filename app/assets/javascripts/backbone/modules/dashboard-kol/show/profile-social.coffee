Robin.module 'DashboardKol.Show', (Show, App, Backbone, Marionette, $, _)->

  login_template = _.template """
    <div class="col-md-2 cell">
      <button class="btn full-width social-login" id="<%= provider %>"><%= polyglot.t('dashboard_kol.profile_tab.add_account') %></button>
    </div>
  """
  logged_in_template = _.template """
    <div class="col-md-3 cell social-label">
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
      @parent = opts.parent

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
      parent = @parent
      @interval = flip(setInterval) 500, =>
        if @connect_window.closed
          clearInterval @interval
          $.get "/kols/get_current_kol", (data) =>
            console.log data.provide_info
            #  有错误返回，表示添加没有成功
            if data.provide_info.error
              swal(data.provide_info.error);
            else if data.provide_info.identity
              @model.set "identities", data.identities
              App.currentKOL.set "identities", data.identities
              $.growl "#{polyglot.t('common.add_success')}", type: "success",
#              Backbone.trigger('showSocialAccount',new Robin.Models.Identity(data.identities[0]));
              parent.refreshSocialList()
              setTimeout ->
                identity_id = data.provide_info.identity.id
                console.log ".identity-#{identity_id} .edit-account"
                $(".identity-" + identity_id + " .edit-account").trigger("click")
              , 200


    serializeData: ->
      k: @model.toJSON()

  Show.ProfileSocialListView = Backbone.Marionette.LayoutView.extend
    template: 'modules/dashboard-kol/show/templates/profile-social-list'
    ui:
      modal_account: "#modal-account"

    events:
      "click .delete-account": "deleteSocialAccount"
      "click .edit-account"  : "editSocialAccount"

    regions:
      modal_account: "#modal-account"

    initialize:(opts) ->
      Backbone.on('showSocialAccount', this.showSocialAccount, this);
      @parent = opts.parent

    onRender: ->
      console.log "on render"

    editSocialAccount: (e) ->
      e.preventDefault()
      identity_id = e.target.id
      identity = new Robin.Models.Identity {id: identity_id}
      identity.fetch
        success: (c, r, o) =>
          this.showSocialAccount(c)

    showSocialAccount: (identity) ->
      console.log "modal_account"
      if this.getRegion('modal_account')
        console.log identity
        @modal_account_view = new Show.ProfileSocialModalAccount
          model: identity
          title: "edit_social"
          parent: this
        console.log @modal_account_view
        @showChildView 'modal_account', @modal_account_view
        @ui.modal_account.modal('show')

    deleteSocialAccount: (e) ->
      e.preventDefault()
      identity_id = e.currentTarget.id
#      identity = new Robin.Models.Identity {id: identity_id}
#      identity.fetch
#        success: (c, r, o) =>
#          c.destroy
      parent =  @parent
      $.ajax
        type: "DELETE"
        url: '/identities/' + identity_id,
        dataType: 'json',
        success: (data) ->
          @collection =  data.newest_identities
          @render
          parent.initSocialList()
          $.growl "#{polyglot.t('common.delete_success')}", {type: "success"}
        error: (xhr, textStatus) ->
          $.growl textStatus,
            type: "#{polyglot.t('common.delete_fail')}",


    serializeData: () ->
      items: @collection.toJSON()
      test: @options.test

