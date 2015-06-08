Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.EmailsAnalyticsPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/analytics/templates/emails-analytics',

    renderEmailAnalytics: function(id) {
      var collection = this.collection;
      this.collection.fetch({
        success: function(){
          if (collection.length == 0) {
            $('.releases-toolbar').hide();
          }
          id = ( id == undefined ? collection.models[0].get('id') : id );
          $.get('/news_rooms/' + id +'/email_analytics', function(data){
            window.$data = data;
            var mail = data.mail.total;
            var mailStatistics = [mail.sent, mail.delivered, mail.opened, mail.dropped]

            $('#emails-analytics').highcharts({
              chart: {
                zoomType: 'xy',
              },
              title: {
                text: 'SmartRelease Email Statistics'
              },
              xAxis: [{
                categories: ['Sent', 'Delivered', 'Opened', 'Dropped']
              }],
              yAxis: [{ // Primary yAxis
                labels: {
                  format: '',
                  style: {
                    color: Highcharts.getOptions().colors[1]
                  }
                }
              }, { // Secondary yAxis
                title: {
                  text: 'Emails',
                    style: {
                      color: Highcharts.getOptions().colors[0]
                    }
                },
                labels: {
                  format: '{value}',
                  style: {
                    color: Highcharts.getOptions().colors[0]
                  }
                },
                opposite: true
              }],
              tooltip: {
                shared: true
              },
              legend: {
                enabled: false,
                layout: 'vertical',
                align: 'left',
                x: 120,
                verticalAlign: 'top',
                y: 100,
                floating: true,
                backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
              },
              series: [{
                name: 'Emails',
                type: 'column',
                yAxis: 1,
                data: mailStatistics
              }]
            });
          });
        }
      });
      Analytics.layout.$el.find('.emails-label').tab('show');
    },

    initDataTable: function(){
      var self = this;
      var table = this.$el.find('table').DataTable({
        "info": false,
        "searching": false,
        "lengthChange": false,
        "order": [[ 1, 'desc' ]],
        "pageLength": 25,
        "columns": [
          { "width": "30% !important" },
          null,
          null,
          null,
          null,
          null,
          null
        ],
        dom: 'T<"clear">lfrtip'
      });
    },

  });

  Analytics.EmailView = Backbone.Marionette.ItemView.extend({
    tagName: "tr",
    template: "modules/analytics/templates/_email"
  });

  Analytics.EmailsListCompositeView = Backbone.Marionette.CompositeView.extend({
    childView: Analytics.EmailView,

    childViewContainer: "tbody",

    template: "modules/analytics/templates/emails-list",

    onRender: function(){
      this.initDataTable();
    },

    initDataTable: function(){
      var self = this;
      var table = this.$el.find('table').DataTable({
        "info": false,
        "searching": false,
        "lengthChange": false,
        "pageLength": 10,
      });

    },
  });

});