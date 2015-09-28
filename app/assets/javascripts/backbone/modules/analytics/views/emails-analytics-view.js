Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.EmailsAnalyticsPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/analytics/templates/emails-analytics',

    renderEmailAnalytics: function(id, type_param) {
      var collection = this.collection;
      this.collection.fetch({
        success: function(){
          if (collection.length == 0) {
            $('.releases-toolbar').hide();
          }
          id = ( id == undefined ? collection.models[0].get('id') : id );
          var type = '';
          if(type_param && type_param == 'release') {
            type = 'release';
          }

          var start = new Date($('#start-email-date-input').val());
          var end = new Date($('#end-email-date-input').val());

          $.get('/news_rooms/' + id +'/email_analytics', { start_date: start, end_date: end, type: type }, function(data){

            if (data == 0) {
              $('#emails-analytics').html('<p class="old_content">' + polyglot.t('analytics.email_old_content') + '</p>');
              return;
            }

            var mail = data.mail.total;
            var mailStatistics = [mail.sent, mail.delivered, mail.opened, mail.dropped]

            $('#emails-analytics').highcharts({
              chart: {
                zoomType: 'xy',
              },
              title: {
                text: polyglot.t('analytics.statisitcs')
              },
              xAxis: [{
                categories: [polyglot.t('analytics.sent'), polyglot.t('analytics.delivered'), polyglot.t('analytics.opened'), polyglot.t('analytics.dropped')]
              }],
              yAxis: [{ // Primary yAxis
                labels: {
                  format: '',
                  style: {
                    color: Highcharts.getOptions().colors[1]
                  }
                },
                title: {
                  text: polyglot.t("analytics.values"),
                  style: {
                    color: Highcharts.getOptions().colors[1]
                  }
                }
              }, { // Secondary yAxis
                title: {
                  text: polyglot.t('analytics.emails'),
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
                name: polyglot.t('analytics.emails'),
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

  Analytics.EmailsDroppedListCompositeView = Backbone.Marionette.CompositeView.extend({
    childView: Analytics.EmailView,

    childViewContainer: "tbody",

    template: "modules/analytics/templates/emails-dropped-list",

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
