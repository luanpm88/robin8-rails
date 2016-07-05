#= require cable

@App = {}

$(window).load ->
  App.cable = Cable.createConsumer("/cable")
  App.cable.subscriptions.create { channel: 'QrCodeLoginChannel', uuid: $(".uuid").val() },
    connected: ->

    disconnected: ->

    received: (data) ->
      window.location = "/users/get_user_by_token?token=" + data["token"]
