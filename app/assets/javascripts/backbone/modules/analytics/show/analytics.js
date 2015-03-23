Robin.module('Analytics.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.AnalyticsPage = Backbone.Marionette.LayoutView.extend({
    template: 'modules/analytics/show/templates/analytics',

    events: {
      'click #news-room-select': 'changeNewsRoom'
    },

    initialize: function(){
      this.newsRooms = new Robin.Collections.NewsRooms();
      this.newsRooms.fetch();
    },

    onShow: function() {
      var newsRooms = this.newsRooms;
      this.newsRooms.fetch({
        success: function(){
          $.get('/news_rooms/' + newsRooms.models[0].get('id') +'/analytics', function(data){
            console.log(data);
            window.data = data;
            arr = _.map(data, function(n){ return [n.table.date, parseInt(n.table.pageViews), parseInt(n.table.sessions)] })
            arr = _.union([['Date', 'Sessions', 'Page Views']], arr);
            google.load("visualization", "1", {packages:["corechart"]});
            google.setOnLoadCallback(drawChart);
            function drawChart() {
              var data = google.visualization.arrayToDataTable(arr);

              var options = {
                title: 'Sessions and Page Views',
                hAxis: {title: 'Dates',  titleTextStyle: {color: '#333'}},
                vAxis: {minValue: 0}
              };

              var chart = new google.visualization.AreaChart(document.getElementById('first-chart'));
              chart.draw(data, options);
            }
          })
        }
      })
    },

    // changeNewsRoom: function(e){
    //   console.log(e);
    // }


      


      // //Likes and views section
      
      // _(['likes-over-time','views-over-time']).each(function(x){
      //     this.$('#'+x).highcharts({
      //         title: {
      //             text: 'All Releases',
      //             x: -20 //center
      //         },
      //         xAxis: {
      //             categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      //                 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
      //         },
      //         yAxis: {
      //             title: {
      //                 text: 'Likes'
      //             },
      //             plotLines: [{
      //                 value: 0,
      //                 width: 1,
      //                 color: '#808080'
      //             }]
      //         },
      //         legend: {
      //             layout: 'vertical',
      //             align: 'right',
      //             verticalAlign: 'middle',
      //             borderWidth: 0
      //         },
      //         series: [{
      //             name: 'First Release',
      //             data: [17.0, 16.9, 19.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 19.6]
      //         }, {
      //             name: 'Second Release',
      //             data: [10, 18, 15.7, 11.3, 17.0, 22.0, 24.8, 24.1, 20.1, 14.1, 18.6, 12.5]
      //         }, {
      //             name: 'Third Release',
      //             data: [9, 0.6, 3.5, 8.4, 13.5, 17.0, 18.6, 17.9, 14.3, 9.0, 3.9, 1.0]
      //         }, {
      //             name: 'Fourth Release',
      //             data: [3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]
      //         }]
      //     });
      // });

      // ///Emails analytics

      // this.$('#emails-analytics').highcharts({
      //   chart: {
      //     zoomType: 'xy',
      //   },
      //   title: {
      //     text: 'Email Marketing'
      //   },
      //   xAxis: [{
      //     categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      //                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
      //   }],
      //   yAxis: [{ // Primary yAxis
      //     labels: {
      //     format: '{value}',
      //     style: {
      //       color: Highcharts.getOptions().colors[1]
      //     }
      //   },
      //   title: {
      //     text: 'Emails Sent',
      //     style: {
      //       color: Highcharts.getOptions().colors[1]
      //     }
      //   }
      // }, { // Secondary yAxis
      //   title: {
      //     text: 'Open Rate',
      //       style: {
      //         color: Highcharts.getOptions().colors[0]
      //       }
      //     },
      //     labels: {
      //       format: '{value} %',
      //       style: {
      //         color: Highcharts.getOptions().colors[0]
      //       }
      //     },
      //     opposite: true
      //   }],
      //   tooltip: {
      //     shared: true
      //   },
      //   legend: {
      //     layout: 'vertical',
      //     align: 'left',
      //     x: 120,
      //     verticalAlign: 'top',
      //     y: 100,
      //     floating: true,
      //     backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
      //   },
      //   series: [{
      //     name: 'Open Rate',
      //     type: 'column',
      //     yAxis: 1,
      //     data: [49.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1, 95.6, 54.4],
      //     tooltip: {
      //       valueSuffix: ' %'
      //     }
      //   }, {
      //     name: 'Emails Sent',
      //     type: 'spline',
      //     data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6],
      //   }]
      // })

      // ///Sentiment gauge

      // var gaugeOptions = {
      //   chart: {
      //     type: 'solidgauge'
      //   },
      //   title: null,
      //   pane: {
      //     center: ['50%', '85%'],
      //     size: '140%',
      //     startAngle: -90,
      //     endAngle: 90,
      //     background: {
      //       backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || '#EEE',
      //       innerRadius: '60%',
      //       outerRadius: '100%',
      //       shape: 'arc'
      //     }
      //   },
      //   tooltip: {
      //     enabled: false
      //   },
      //   // the value axis
      //   yAxis: {
      //     stops: [
      //       [0.1, '#55BF3B'], // green
      //       [0.5, '#DDDF0D'], // yellow
      //       [0.9, '#DF5353'] // red
      //     ],
      //     lineWidth: 0,
      //     minorTickInterval: null,
      //     tickPixelInterval: 400,
      //     tickWidth: 0,
      //     title: {
      //       y: -70
      //     },
      //     labels: {
      //       y: 16
      //     }
      //   },
      //   plotOptions: {
      //     solidgauge: {
      //       dataLabels: {
      //         y: 5,
      //         borderWidth: 0,
      //         useHTML: true
      //       }
      //     }
      //   }
      // };

      // this.$('#sentiment').highcharts(Highcharts.merge(gaugeOptions, {
      //   yAxis: {
      //     min: 0,
      //     max: 100,
      //     title: {
      //       text: 'Positive',
      //       y: 20
      //     }
      //   },
      //   credits: {
      //     enabled: false
      //   },
      //   series: [{
      //     name: 'Polarity',
      //     data: [50],
      //     dataLabels: {
      //       format: '<div style="text-align:center"><span style="font-size:25px;color:' +
      //         ((Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black') + '">{y}</span><br/>' +
      //         '<span style="font-size:12px;color:silver">%</span></div>'
      //     },
      //     tooltip: {
      //       valueSuffix: ' %'
      //     }
      //   }]
      // }));

    // }

  });
});