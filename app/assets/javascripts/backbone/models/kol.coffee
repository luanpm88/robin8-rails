Robin.Models.KOL = Backbone.Model.extend(
  url: '/kols/get_current_kol'
  signOut: (data, options)=>
    model = this
    options =
      url: '/kols/sign_out'
      type: 'GET'

    success = options.success
    options.success = (resp)->
      if !model.set(model.parse(resp, options), options)
        return false
      if success
        success(model, resp, options)
      model.trigger('sync', model, resp, options)

    @sync('read', this, options)

  cancelSubscription: (data, options) ->
    model = this
    options =
      url: '/payments/destroy_subscription'
      type: 'DELETE'
    success = options.success
    options.success = (resp) ->
    if !model.set(model.parse(resp, options), options)
      return false
    if success
      success(model, resp, options)
    model.trigger('sync', model, resp, options)

    return @sync('read', this, options);

  cancelAddon: (data, options) ->
    model = this
    options =
      url: '/payments/' + data.id + '/destroy_add_on'
      type: 'DELETE'
    success = options.success
    options.success = (resp)=>
    if !model.set(model.parse(resp, options), options)
      return false
    if success
      success(model, resp, options)
    model.trigger('sync', model, resp, options)
    return @sync('read', this, options)
)