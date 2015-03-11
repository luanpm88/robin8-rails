Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.AuthorStatsView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/author_stats/show',
    initialize: function(options){
      this.releaseModel = options.releaseModel;
    },
    onRender: function(){
      this.initHighcharts();
    },
    initHighcharts: function(){
      this.$el.highcharts({
        chart: {
          type: 'column',
          width: '550'
        },
        title: {
          text: 'Average Syntactic Stats for ' + this.model.get("full_name")
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
          name: this.model.get("full_name") + "'s average",
          data: [
            Math.ceil(this.model.get('stats').syntactic.characters_count.mean),
            Math.ceil(this.model.get('stats').syntactic.words_count.mean),
            Math.ceil(this.model.get('stats').syntactic.sentences_count.mean),
            Math.ceil(this.model.get('stats').syntactic.paragraphs_count.mean),
            Math.ceil(this.model.get('stats').syntactic.nouns_count.mean),
            Math.ceil(this.model.get('stats').syntactic.adjectives_count.mean),
            Math.ceil(this.model.get('stats').syntactic.adverbs_count.mean),
            Math.ceil(this.model.get('stats').syntactic.people_count.mean),
            Math.ceil(this.model.get('stats').syntactic.places_count.mean),
            Math.ceil(this.model.get('stats').syntactic.organizations_count.mean)
          ]
        }, {
          name: 'Your release',
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
