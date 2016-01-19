Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _)->
  Show.StatsCampaign = Backbone.Marionette.LayoutView.extend
    template: 'modules/smart-campaign/show/templates/stats-campaign'

    templateHelpers:
      formatDate: (d) ->
        datetime = new Date(d);
        year = datetime.getFullYear();
        month = if datetime.getMonth() + 1 < 10 then "0" + (datetime.getMonth() + 1) else datetime.getMonth() + 1;
        date = if datetime.getDate() < 10 then "0" + datetime.getDate() else datetime.getDate();
        hour = if datetime.getHours() < 10 then "0" + datetime.getHours() else datetime.getHours();
        minute = if datetime.getMinutes() < 10 then "0" + datetime.getMinutes() else datetime.getMinutes();
        second = if datetime.getSeconds() < 10 then "0" + datetime.getSeconds() else datetime.getSeconds();
        return year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second;
      timestamp: (d) ->
        date = new Date d
        date.getTime()

    regions:
      content: "#campaign-content"
      analyticsRegion: '#analytics-campaign-text'
      kol_list: '#kol-list'

    ui:
      startDatePicker: "#datetimepicker6"
      endDatePicker: "#datetimepicker7"
      createCampagin: "#create-campagin"

    initialize: (options) ->
      @options = options
      @statsChart = null

    onRender: () ->
      console.log 'stats  on render'
      that = this
      _.defer =>
        this.statsChart = echarts.init(document.getElementById('day_stats'))
      $.ajax
        type: "get"
        url: "/campaign/" + that.model.id + "/day_stats",
        dataType: 'json',
        success: (data) =>
          that.initStatsChat(data[0], data[1], data[2], data[3])
        error: (xhr, textStatus) ->
          $.growl textStatus,
            type: "danger",
      $.ajax
        type: "get"
        url: "/campaign/" + that.model.id + "/kol_list" ,
        dataType: 'json',
        success: (data) =>
          @stats_kol_view = new Robin.SmartCampaign.Show.StatsKol
            kol_list_data: data, campaign: that.model
          @showChildView 'kol_list', @stats_kol_view

        error: (xhr, textStatus) ->
          $.growl textStatus,
            type: "danger",


    initStatsChat: (per_budget_type, label, total_clicks, avail_clicks) ->
      if per_budget_type == "click"
        option = {
          title : {
            text: '',
            subtext: ''
          },
          tooltip : {
            trigger: 'axis'
          },
          legend: {
            data:[ polyglot.t("smart_campaign.stats.total_click"), polyglot.t("smart_campaign.stats.avail_click")]
          },
          toolbox: {
            show : true,
          },
          calculable : true,
          xAxis : [
            {
              type : 'category',
              boundaryGap : false,
              data : label
            }
          ],
          yAxis : [
            {
              type : polyglot.t("smart_campaign.stats.click_unit"),
            }
          ],
          series : [
            {
              name: polyglot.t("smart_campaign.stats.total_click"),
              type:'line',
              data: total_clicks

            },
            {
              name: polyglot.t("smart_campaign.stats.avail_click"),
              type:'line',
              data:avail_clicks,
            }
          ]
        };
      else
        option = {
          title : {
            text: '',
            subtext: ''
          },
          tooltip : {
            trigger: 'axis'
          },
          legend: {
            data:[ polyglot.t("smart_campaign.stats.total_click")]
          },
          toolbox: {
            show : true,
          },
          calculable : true,
          xAxis : [
            {
              type : 'category',
              boundaryGap : false,
              data : label
            }
          ],
          yAxis : [
            {
              type : polyglot.t("smart_campaign.stats.click_unit"),
            }
          ],
          series : [
            {
              name: polyglot.t("smart_campaign.stats.total_click"),
              type:'line',
              data: total_clicks

            }
          ]
        };
      @statsChart.setOption(option)


  Show.StatsKol = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/stats-kol'

    ui:
      table: "#campaigns-table22"
      screenshotModal: "#screenshotModal"
      screenshot: ".screenshot"
      screenshot_detail: "#screenshot_detail"


    events:
      'click @ui.screenshot': 'showScreenshot'

    templateHelpers:
      formatDate: (d) ->
        datetime = new Date(d);
        year = datetime.getFullYear();
        month = if datetime.getMonth() + 1 < 10 then "0" + (datetime.getMonth() + 1) else datetime.getMonth() + 1;
        date = if datetime.getDate() < 10 then "0" + datetime.getDate() else datetime.getDate();
        hour = if datetime.getHours() < 10 then "0" + datetime.getHours() else datetime.getHours();
        minute = if datetime.getMinutes() < 10 then "0" + datetime.getMinutes() else datetime.getMinutes();
        second = if datetime.getSeconds() < 10 then "0" + datetime.getSeconds() else datetime.getSeconds();
        return year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second;
      timestamp: (d) ->
        date = new Date d
        date.getTime()

    collectionEvents:
      "reset add remove change": "render"

    initialize: (options) ->
      @options = options
      console.log @options.kol_list_data

    onRender: () ->
      @ui.table.DataTable
        info: false
        searching: false
        lengthChange: false
        pageLength: 10
        autoWidth: false
        order: [[ 1, "desc" ]]
        language:
          paginate:
            previous: polyglot.t('smart_campaign.prev'),
            next: polyglot.t('smart_campaign.next')

    showScreenshot: (e) ->
      console.log $(e.currentTarget)
      console.log $(e.currentTarget).find("img").attr("data-big")
      big_url = $(e.currentTarget).find("img").attr("data-big")
      console.log(big_url)
      @ui.screenshot_detail.attr("src",big_url)
      @ui.screenshotModal.modal('show')


    serializeData: () ->
      items: @options.kol_list_data
      campaign: @options.campaign
