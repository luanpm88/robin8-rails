Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.WebAnalyticsPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/analytics/templates/analytics',

    renderAnalytics: function(id) {

      var collection = this.collection;
      this.collection.fetch({
        success: function(){

          if (collection.length == 0) {
            $('.releases-toolbar').hide();
          }
          id = ( id == undefined ? collection.models[0].get('id') : id );

          var start = new Date($('#start-date-input').val());
          var end = new Date($('#end-date-input').val());

          $.get('/news_rooms/' + id +'/web_analytics/', { start_date: start, end_date: end }, function(data){

            var dates = _.map(data.web.dates, function(date){
              var split = date.match(/.{1,4}/g);
              var monthDate = split[1].match(/.{1,2}/g);
              var date = split[0] + '-' + monthDate[0] + '-' + monthDate[1];
              return date
            });
            var radix10ParseInt = _.partial(parseInt, _, 10);
            var sessions = _.map(data.web.sessions, radix10ParseInt);
            var pageViews = _.map(data.web.views, radix10ParseInt);
            var mailViews = _.map(data.web.mailViews, radix10ParseInt);

            $('#news-rooms').highcharts({
              chart: {
                zoomType: 'xy',
              },
              title: {
                text: polyglot.t("analytics.visits")
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
                text: polyglot.t("analytics.page_views"),
                style: {
                  color: Highcharts.getOptions().colors[1]
                }
              }
            }, { // Secondary yAxis
              title: {
                text: polyglot.t("analytics.newsrooms_views"),
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
                name: polyglot.t("analytics.newsrooms_views"),
                type: 'column',
                yAxis: 1,
                data: sessions
              }, {
                name: polyglot.t("analytics.emails"),
                type: 'column',
                yAxis: 1,
                data: mailViews
              }, {
                name: polyglot.t("analytics.page_views"),
                type: 'column',
                data: pageViews,
              }]
            });

          });
        }
      })
    }

  });

  Analytics.WebFilterCollectionView = Backbone.Marionette.CollectionView.extend({
    tagName: 'select',
    className: 'form-control change-web-news-room'
  });

  Analytics.WebFilterItemView = Backbone.Marionette.ItemView.extend({

    template: 'modules/analytics/templates/filter',
    tagName: 'option',

    onRender: function() {
      this.$el.val(this.model.id);
    }

  });

  Analytics.EmailsFilterCollectionView = Backbone.Marionette.CollectionView.extend({
    tagName: 'select',
    className: 'form-control change-emails-news-room'
  });

  Analytics.EmailsFilterItemView = Backbone.Marionette.ItemView.extend({

    template: 'modules/analytics/templates/filter',
    tagName: 'option',

    onRender: function() {
      this.$el.val(this.model.id);
    }

  });


});
