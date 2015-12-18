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
      that = this
      _.defer =>
        this.statsChart = echarts.init(document.getElementById('day_stats'))
      $.ajax
        type: "get"
        url: "/campaign/" + that.model.id + "/day_stats" ,
        dataType: 'json',
        success: (data) =>
          that.initStatsChat(data[0], data[1], data[2])
        error: (xhr, textStatus) ->
          $.growl textStatus,
            type: "danger",
      $.ajax
        type: "get"
        url: "/campaign/" + that.model.id + "/kol_list" ,
        dataType: 'json',
        success: (data) =>
#          console.log data[0]
#          console.log data[0].kol.first_name
          @stats_kol_view = new Robin.SmartCampaign.Show.StatsKol
            kol_list_data: data
          @showChildView 'kol_list', @stats_kol_view

        error: (xhr, textStatus) ->
          $.growl textStatus,
            type: "danger",


    initStatsChat: (label, total_clicks, avail_clicks) ->
      option = {
        title : {
          text: '',
          subtext: ''
        },
        tooltip : {
          trigger: 'axis'
        },
        legend: {
          data:['总点击', '有效点击']
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
            type : '次数',
          }
        ],
        series : [
          {
            name:'总点击',
            type:'line',
            data: total_clicks

          },
          {
            name:'有效点击',
            type:'line',
            data:avail_clicks,
          }
        ]
      };
      @statsChart.setOption(option)


  Show.StatsKol = Backbone.Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/stats-kol'

    ui:
      table: "#campaigns-table22"

    templateHelpers:
      formatDate: (d) ->
        date = new Date d
        monthNum = parseInt(date.getMonth()) + 1
        d = date.getDate()
        y = date.getFullYear()
        month =  monthNum
        h = date.getHours();
        m = date.getMinutes();
        "#{y}-#{month}-#{d} #{h}:#{m}"
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
#        columnDefs: [sortable: false, targets: [0]]
#        order: [[ 1, "desc" ]]
        language:
          paginate:
            previous: polyglot.t('smart_campaign.prev'),
            next: polyglot.t('smart_campaign.next')

    serializeData: () ->
      items: @options.kol_list_data
