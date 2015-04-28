Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.AnalyticsPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/analytics/templates/analytics',

    renderAnalytics: function(id) {

      var collection = this.collection;
      this.collection.fetch({
        success: function(){
          if (collection.length == 0) {
            $('.releases-toolbar').hide();
          }
          id = ( id == undefined ? collection.models[0].get('id') : id );
          $.get('/news_rooms/' + id +'/analytics', function(data){

            var dates = _.map(data.web.dates, function(date){
              var split = date.match(/.{1,4}/g);
              var monthDate = split[1].match(/.{1,2}/g);
              var date = split[0] + '-' + monthDate[0] + '-' + monthDate[1];
              return date
            });
            var sessions = _.map(data.web.sessions, function(session){
              var session = parseInt(session);
              return session;
            });
            var pageViews = _.map(data.web.views, function(pageView){
              var pageView = parseInt(pageView);
              return pageView;
            });
            var mail = data.mail.total;
            var mailStatistics = [mail.sent, mail.delivered, mail.opened, mail.dropped]

            $('#news-rooms').highcharts({
              chart: {
                zoomType: 'xy',
              },
              title: {
                text: 'Newsroom and Releases Visits'
              },
              xAxis: [{
                categories: dates
              }],
              yAxis: [{ // Primary yAxis
                labels: {
                format: '{value}',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              },
              title: {
                text: 'Page Views',
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              }
            }, { // Secondary yAxis
              title: {
                text: 'Newsroom Views',
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
                name: 'Newsroom Views',
                type: 'column',
                yAxis: 1,
                data: sessions
              }, {
                name: 'Page Views',
                type: 'column',
                data: pageViews,
              }]
            });


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
      })
    }
  });

  Analytics.AnalyticsFilterCollectionView = Backbone.Marionette.CollectionView.extend({
    tagName: 'select',
    className: 'form-control change-news-room'
  })
  
  Analytics.AnalyticsFilterItemView = Backbone.Marionette.ItemView.extend({

    template: 'modules/analytics/templates/filter',
    tagName: 'option',

    onRender: function() {
      this.$el.val(this.model.id);
    }

  })
  

});