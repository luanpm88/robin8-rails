Robin.module 'Campaigns.Show', (Show, App, Backbone, Marionette, $, _)->

  Show.ClaimReportDialog = Backbone.Marionette.LayoutView.extend
    template: 'modules/campaigns/show/templates/article-wechat-claim'

    ui:
      claimText: '#claim-text'
      errorBlock: 'p#report-error'

    events:
      "click #claim-reason-save": "claimReasonSave"

    serializeData: () ->
      reportId: @options.reportId
      reportPeriod: @options.reportPeriod

    claimReasonSave: () ->
      text = @ui.claimText.val()
      if text == ''
        @ui.claimText.parent().addClass("has-error")
        @ui.errorBlock.removeClass("hidden")
        return
      else if @ui.claimText.parent().hasClass("has-error")
        @ui.claimText.parent().removeClass("has-error")
        @ui.errorBlock.addClass("hidden")
      if text != ''
        data = {}
        data["reason"] = text
        data["reportId"] = @options.reportId
        $.post "/campaign/wechat_report/claim/", data, (data) =>
          if data.status == "Claimed"
            $.growl({message: "Claim was sent to Robin8 admin successfully."
            },{
              type: 'success'
            })
            $('#modal').modal('hide')
            $('body').removeClass('modal-open')
            $('.modal-backdrop').remove()
            $('.fade').remove()
          else
            $.growl({message: "Something went wrong. Please, try again."
            },{
              type: 'danger'
            })
