Robin.module "Transaction", (Transaction, Robin, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    showPage: ()->
      Transaction.Show.Controller.showIndex()

  Transaction.on 'start', () ->
    API.showPage()
    $('#nav-transactions').parent().addClass('active')
