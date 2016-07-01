#= require cable

@App = {}
App.cable = Cable.createConsumer("/cable")
