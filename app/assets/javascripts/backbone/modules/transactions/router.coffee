Robin.module 'Transaction', (Transaction, App, Backbone, Marionette, $, _) ->

  Transaction.Router = Backbone.Marionette.AppRouter.extend
    appRoutes:
      "": "index",
      "transactions/index": "showIndex",
      "transactions/show": "showDetail",

