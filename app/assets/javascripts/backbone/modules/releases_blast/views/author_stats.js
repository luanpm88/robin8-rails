Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.AuthorStatsView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/author_stats/show',
    initialize: function(options){
      this.releaseModel = options.releaseModel;
      this.authorModel = options.authorModel;
    },
    onRender: function(){
      this.initHighcharts();
    },
    initHighcharts: function(){
      var series_data = [
        Math.ceil(this.model.get('syntactic').characters_count.mean),
        Math.ceil(this.model.get('syntactic').words_count.mean),
        Math.ceil(this.model.get('syntactic').sentences_count.mean),
        Math.ceil(this.model.get('syntactic').paragraphs_count.mean),
        Math.ceil(this.model.get('syntactic').nouns_count.mean),
        Math.ceil(this.model.get('syntactic').adjectives_count.mean),
        Math.ceil(this.model.get('syntactic').adverbs_count.mean),
        Math.ceil(this.model.get('syntactic').people_count.mean),
        Math.ceil(this.model.get('syntactic').places_count.mean),
        Math.ceil(this.model.get('syntactic').organizations_count.mean)
      ];
      
      if (Robin.currentUser.get('locale') == 'zh'){
        series_data = [
          Math.ceil(this.model.get('syntactic').characters_count.max),
          Math.ceil(this.model.get('syntactic').words_count.max),
          Math.ceil(this.model.get('syntactic').sentences_count.max),
          Math.ceil(this.model.get('syntactic').paragraphs_count.max),
          Math.ceil(this.model.get('syntactic').nouns_count.max),
          Math.ceil(this.model.get('syntactic').adjectives_count.max),
          Math.ceil(this.model.get('syntactic').adverbs_count.max),
          Math.ceil(this.model.get('syntactic').people_count.max),
          Math.ceil(this.model.get('syntactic').places_count.max),
          Math.ceil(this.model.get('syntactic').organizations_count.max)
        ];
      }
      
      this.$el.highcharts({
        chart: {
          type: 'column',
          width: '550'
        },
        title: {
          text: 'Average Syntactic Stats for ' + this.authorModel.get("full_name")
        },
        xAxis: {
          type: 'category',
          labels: {
            rotation: -45,
            style: {
              fontSize: '13px',
              fontFamily: 'Verdana, sans-serif'
            }
          },
          categories: [
            'Characters',
            'Words',
            'Sentences',
            'Paragraphs',
            'Nouns',
            'Adjectives',
            'Adverbs',
            'People',
            'Places',
            'Organizations'
          ],
          crosshair: true
        },
        yAxis: {
          type: 'logarithmic',
          title: {
            text: 'Average count'
          }
        },
        legend: {
            enabled: true
        },
        tooltip: {
          headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
          pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
              '<td style="padding:0"><b>{point.y}</b></td></tr>',
          footerFormat: '</table>',
          shared: true,
          useHTML: true
        },
        plotOptions: {
          column: {
            pointPadding: 0.2,
            borderWidth: 0
          }
        },
        series: [{
          name: this.authorModel.get("full_name") + "'s average",
          data: series_data
        }, {
          name: 'Your content',
          data: [
            this.releaseModel.get('characters_count'),
            this.releaseModel.get('word_count'),
            this.releaseModel.get('sentences_count'),
            this.releaseModel.get('paragraphs_count'),
            this.releaseModel.get('nouns_count'),
            this.releaseModel.get('adjectives_count'),
            this.releaseModel.get('adverbs_count'),
            this.releaseModel.get('people_count'),
            this.releaseModel.get('places_count'),
            this.releaseModel.get('organizations_count')
          ]
        }]
      });
    }
  });
});
