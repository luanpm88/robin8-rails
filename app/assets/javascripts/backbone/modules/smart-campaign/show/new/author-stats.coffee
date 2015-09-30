Robin.module 'SmartCampaign.Show', (Show, App, Backbone, Marionette, $, _) ->

  Show.AuthorStatsView = Marionette.ItemView.extend
    template: 'modules/smart-campaign/show/templates/author_stats/show',
    initialize: (options) ->
      this.campaignModel = options.campaignModel
      this.authorModel = options.authorModel

    onRender: () ->
      this.initHighcharts()

    initHighcharts: () ->
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
          data: [
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
          ]
        }, {
          name: 'Your campaign',
          data: [
            this.campaignModel.get('counter').characters_count,
            this.campaignModel.get('counter').word_count,
            this.campaignModel.get('counter').sentences_count,
            this.campaignModel.get('counter').paragraphs_count,
            this.campaignModel.get('counter').nouns_count,
            this.campaignModel.get('counter').adjectives_count,
            this.campaignModel.get('counter').adverbs_count,
            this.campaignModel.get('counter').people_count,
            this.campaignModel.get('counter').places_count,
            this.campaignModel.get('counter').organizations_count
          ]
        }]
      })



