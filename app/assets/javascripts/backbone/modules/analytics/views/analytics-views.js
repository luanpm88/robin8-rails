Robin.module('Analytics', function(Analytics, App, Backbone, Marionette, $, _){
  Analytics.AnalyticsPage = Backbone.Marionette.ItemView.extend({
    template: 'modules/analytics/templates/analytics',

    onShow: function() {
      // this.renderAnalytics();
    },

    renderAnalytics: function(id) {
      var collection = this.collection;
      this.collection.fetch({
        success: function(){
          id = ( id == undefined ? collection.models[0].get('id') : id );
          $.get('/news_rooms/' + id +'/analytics', function(data){
            mail = data.mail
            arr = _.map(data.web, function(n){ return [n.table.date, parseInt(n.table.pageViews), parseInt(n.table.sessions)] })
            arr = _.union([['Date', 'Sessions', 'Page Views']], arr);
            google.load("visualization", "1", {packages:["corechart"]});
            function drawAreaChart() {
              var data = google.visualization.arrayToDataTable(arr);

              var options = {
                title: 'Newsroom and Releases Visits',
                hAxis: {title: 'Dates',  titleTextStyle: {color: '#333'}},
                vAxis: {
                  minValue: 0,
                  viewWindow: {
                    min:0
                  }
                }
              };

              var chart = new google.visualization.AreaChart(document.getElementById('first-chart'));
              chart.draw(data, options);
            }

            function drawColumnChart() {
              var data = google.visualization.arrayToDataTable([
                ['Element', 'Emails', { role: 'style' }],
                ['Sent', parseInt(mail.total.sent), 'blue'],
                ['Delivered', parseInt(mail.total.delivered), 'green'],  
                ['Opened', parseInt(mail.total.opened), 'silver'],   
                ['Dropped', parseInt(mail.total.dropped), 'red']
              ]);
              var options = {
                title: 'SmartRelease Email Statistics',
                hAxis: {title: '',  titleTextStyle: {color: '#333'}},
                vAxis: {
                  minValue: 0,
                  viewWindowMode:'explicit',
                  viewWindow: {
                    min:0
                  }
                }
              };
              var chart = new google.visualization.ColumnChart(document.getElementById('second-chart'));
              chart.draw(data, options);
            }
            drawAreaChart();
            drawColumnChart();
          })
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