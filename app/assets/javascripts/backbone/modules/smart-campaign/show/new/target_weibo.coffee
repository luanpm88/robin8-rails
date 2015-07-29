Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.TargetWeibo = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/targets-tab-weibo'
