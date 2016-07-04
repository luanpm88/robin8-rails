#= require cable

@App = {}
App.cable = Cable.createConsumer("/cable")

App.cable.subscriptions.create { channel: 'QrCodeLoginChannel', uuid: 3000 },
  connected: ->

  disconnected: ->

  received: (data) ->
    window.location = "/users/get_user_by_token?token=" + data["token"]
