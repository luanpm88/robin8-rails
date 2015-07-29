Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.TargetWechat = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/targets-tab-wechat'
