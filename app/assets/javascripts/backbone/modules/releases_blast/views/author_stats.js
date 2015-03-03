Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.AuthorStatsView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/author-stats',
    model: Robin.Models.Author,
    onShow: function(){
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
          }
        },
        yAxis: {
          type: 'logarithmic',
          title: {
            text: 'Average count'
          }
        },
        legend: {
            enabled: false
        },
        tooltip: {
          pointFormat: 'Average count is: <b>{point.y:.1f}</b>'
        },
        series: [{
          name: 'Number',
          data: [
            ['Characters', Math.ceil(this.model.get('stats').syntactic.characters_count.mean)],
            ['Words', Math.ceil(this.model.get('stats').syntactic.words_count.mean)],
            ['Sentences', Math.ceil(this.model.get('stats').syntactic.sentences_count.mean)],
            ['Paragraphs', Math.ceil(this.model.get('stats').syntactic.paragraphs_count.mean)],
            ['Nouns', Math.ceil(this.model.get('stats').syntactic.nouns_count.mean)],
            ['Adjectives', Math.ceil(this.model.get('stats').syntactic.adjectives_count.mean)],
            ['Adverbs', Math.ceil(this.model.get('stats').syntactic.adverbs_count.mean)],
            ['People', Math.ceil(this.model.get('stats').syntactic.people_count.mean)],
            ['Places', Math.ceil(this.model.get('stats').syntactic.places_count.mean)],
            ['Organizations', Math.ceil(this.model.get('stats').syntactic.organizations_count.mean)]
          ],
          dataLabels: {
            enabled: true,
            rotation: -90,
            color: '#FFFFFF',
            align: 'right',
            x: 3,
            y: 10,
            style: {
              fontSize: '10px',
              fontFamily: 'Verdana, sans-serif',
              textShadow: '0 0 3px black'
            }
          }
        }]
      });
    }
  });
});
