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



  Analytics.EmailsListCompositeView = Marionette.CompositeView.extend({
    template: 'modules/analytics/templates/emails-list',
    childView: Analytics.EmailView,
    childViewContainer: "tbody",
    ui: {
      tooltips: "[data-toggle=tooltip]"
    },
    childViewOptions: function() {
      return this.options;
    },
    initialize: function(options){
      // this.pitchContactsCollection = options.pitchContactsCollection;
    },
    onRender: function () {
      var $this = this;
      // this.initDataTable();
      Robin.user = new Robin.Models.User();
      Robin.user.fetch({
        success: function(){
          $this.initDataTable();
        }
      })
      this.scrollToView();
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

    scrollToView: function(){
      var self = this;
      _.defer(function(caller){
        var offset = self.$el.offset();
        offset.left -= 20;
        offset.top -= 20;
        
        $('html, body').animate({
          scrollTop: offset.top,
          scrollLeft: offset.left
        });
      }, this);
    }

  });

  Analytics.EmailView = Marionette.ItemView.extend({
    template: 'modules/analytics/templates/_email',
    tagName: "tr",
    ui: {
      tweetContactButton: '#tweet-contact-button'
    },
    events: {
      "click a.btn-danger":     "removeInfluencer",
      "click a.btn-success":    "addInfluencer",
      "click @ui.tweetContactButton": "tweetContactButtonClicked"
    },
    toggleAddRemove: function(model, collection, options) {
      if (model.get('twitter_screen_name') === this.model.get('screen_name'))
        this.render();
    },
    // tweetContactButtonClicked: function(e){
    //   e.preventDefault();
    //   var self = this;
      
    //   var view = Robin.layouts.main.saySomething.currentView;
    //   text = "Hey @@[Handle] here's a press release you might find interesting: @[Link]";
    //   text = text.replace('@[Handle]', self.model.get('screen_name'));
    //   text = text.replace('@[Link]', self.releaseModel.permalink);
      
    //   $('form.navbar-search-sm').hide();
    //   $('#shrink-links').prop('checked', true);
    //   $('#shrink-links').prop('disabled', true);
    //   $('#createPost').find('textarea').val(text);
    //   $('#createPost').show();
    //   $('.progressjs-progress').show();
      
    //   view.checkAbilityPosting();
    //   view.setCounter();
    //   e.stopPropagation();
    // },
    // addInfluencer: function(e) {
    //   e.preventDefault();
      
    //   var current_model = this.pitchContactsCollection.findWhere({
    //     origin: 'twtrland',
    //     twitter_screen_name: this.model.get('screen_name')
    //   });
      
    //   if (current_model == null){
    //     var model = new Robin.Models.Contact({
    //       origin: 'twtrland',
    //       twitter_screen_name: this.model.get('screen_name'),
    //       first_name: this.model.get('firstName'),
    //       last_name: this.model.get('lastName'),
    //       outlet: "Twitter"
    //     });
    //     this.pitchContactsCollection.add(model);
    //   }
    // },
    // removeInfluencer: function(e) {
    //   e.preventDefault();
      
    //   var model = this.pitchContactsCollection.findWhere({
    //     twitter_screen_name: this.model.get('screen_name'),
    //     origin: 'twtrland'
    //   });
    //   this.pitchContactsCollection.remove(model);
    // },
    initialize: function(options) {
      this.pitchContactsCollection = options.pitchContactsCollection;
      this.releaseModel = options.releaseModel.toJSON().release;
      
      // this.listenTo(this.pitchContactsCollection, 'add remove', this.toggleAddRemove);
    },
    templateHelpers: function(){
      return {
        pitchContactsCollection: this.pitchContactsCollection
      }
    }
  });

});