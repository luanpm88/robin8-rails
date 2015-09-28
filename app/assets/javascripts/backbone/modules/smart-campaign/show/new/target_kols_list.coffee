Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.KolsListLayout = Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/kols-list-layout'
    regions:
      uploadKolsListRegion: '#upload-kols-list'
      selectedKolsListsRegion: '#selected-kols-list'

    initialize: (options) ->
      @model = @options.model

    onRender: ->
      kols_list = new Robin.Collections.KolsLists
      kols_list_upload = new Show.UploadKolsListView
        model: @model
        collection: kols_list
      kols_list.fetch
        success: (c, r, o) =>
          @showChildView 'uploadKolsListRegion', kols_list_upload

      kols_list_view = new Show.SelectedKolListView
        model: @model
      @showChildView 'selectedKolsListsRegion', kols_list_view

  Show.UploadKolsListView = Marionette.ItemView.extend

    template: 'modules/smart-campaign/show/templates/upload-kols-list'
    className: 'well'

    ui:
      form: 'form'
      kolsListSelect: 'select'

    serializeData: () ->
      items: @options.collection.models

    initialize: (options) ->
      @model = @options.model

    attributes: 'style': 'box-shadow: none; border: 1px solid #ccc;'

    events:
      'change @ui.kolsListSelect': 'kolsSelectChanged'

    collectionEvents: 'reset add remove': 'render'

    onRender: () ->
      if @model.get("kols")?
        if @model.get("kols").length > 0
          $('#next-step').removeAttr('disabled')
      else if @model.get("weibo")?
        if @model.get("weibo").length > 0
          $('#next-step').removeAttr('disabled')
      else if @model.get("kols_list_contacts")?
        if @model.get("kols_list_contacts").length > 0
          $('#next-step').removeAttr('disabled')
        else
          $('#next-step').prop("disabled",true)
      else
        $('#next-step').prop("disabled",true)

    kolsSelectChanged: (e) ->
      id = parseInt($(e.currentTarget).val())
      if id != -1
        kols_list = if @model.get('kols_list')? then @model.get('kols_list') else []
        if kols_list.indexOf(id) < 0
          kols_lists_contacts = if @model.get('kols_list_contacts')? then @model.get('kols_list_contacts') else []
          contacts = @options.collection.findWhere({id: id}).attributes.kols_lists_contacts
          _.each contacts, (c) ->
            if kols_lists_contacts.indexOf(c.email) == -1
              kols_lists_contacts.push c
          @model.set('kols_list_contacts',kols_lists_contacts)
          list = @options.collection.findWhere({id: id}).attributes
          kols_list.push(list)
          @model.set('kols_list',kols_list)
          kols_list_view = new Show.SelectedKolListView
            model: @model
          Robin.layouts.main.content.currentView.content.currentView.kolslist_view.selectedKolsListsRegion.show(kols_list_view)


  Show.SelectedKolListView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/selected-kols-list'

    ui:
      deleteContactsButton: '#delete_contacts'
      deleteListButton: '#delete_list'

    events:
      'click @ui.deleteContactsButton': 'deleteContactsButtonClicked'
      'click @ui.deleteListButton': 'deleteListButtonClicked'

    serializeData: () ->
      items: if @options.model.get('kols_list')? then @options.model.get('kols_list') else []

    initialize: () ->
      @model = @options.model

    onRender: () ->
      if @model.get("kols")?
        if @model.get("kols").length > 0
          $('#next-step').removeAttr('disabled')
      else if @model.get("weibo")?
        if @model.get("weibo").length > 0
          $('#next-step').removeAttr('disabled')
      else if @model.get("kols_list_contacts")?
        if @model.get("kols_list_contacts").length > 0
          $('#next-step').removeAttr('disabled')
        else
          $('#next-step').prop("disabled",true)
      else
        $('#next-step').prop("disabled",true)

    deleteContactsButtonClicked: (e) ->
      e.preventDefault()
      target = $ e.currentTarget
      list_id = target.data 'list-id'
      emails_list = []
      kols_list = if @options.model.get('kols_list')? then @options.model.get('kols_list') else []
      _.each kols_list, (c) ->
        if c.id == list_id
          emails_list.push c.kols_lists_contacts
          kols_list.pop c
      @model.set('kols_list',kols_list)
      kols_lists_contacts = if @model.get('kols_list_contacts')? then @model.get('kols_list_contacts') else []
      _.each emails_list[0], (c,index) ->
        if c.kols_list_id  == list_id
          kols_lists_contacts.pop(index)
      @model.set('kols_list_contacts',kols_lists_contacts)
      kols_list_view = new Show.SelectedKolListView
        model: @model
      Robin.layouts.main.content.currentView.content.currentView.kolslist_view.selectedKolsListsRegion.show(kols_list_view)
      kols_list_collection = new Robin.Collections.KolsLists
      kols_list_upload = new Show.UploadKolsListView
        model: @model
        collection: kols_list_collection
      kols_list_collection.fetch
        success: (c, r, o) =>
          Robin.layouts.main.content.currentView.content.currentView.kolslist_view.uploadKolsListRegion.show(kols_list_upload)

    deleteListButtonClicked: (e) ->
      e.preventDefault()
      target = $ e.currentTarget
      kol_id = target.data 'list-id'
      data = {}
      data['id'] = kol_id
      swal {
        title: polyglot.t('smart_campaign.targets_step.delete_list')
        type: 'error'
        showCancelButton: true
        confirmButtonClass: 'btn-danger'
        confirmButtonText: polyglot.t('billing.cancel.yes')
        cancelButtonText: polyglot.t('billing.cancel.no')
      }, (isConfirm) =>
        if isConfirm
          $.ajax
            type: 'DELETE'
            url: '/users/delete_kols_list'
            dataType: 'json'
            data: data
            success: () =>
              @deleteContactsButtonClicked e

