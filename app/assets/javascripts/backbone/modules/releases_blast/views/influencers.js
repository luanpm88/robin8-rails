Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.InfluencerView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/influencers/_influencer',
    tagName: "tr",
    ui: {
      tweetContactButton: '#tweet-contact-button'
    },
    events: {
      "click a.btn-danger":     "removeInfluencer",
      "click a.btn-success":    "addInfluencer",
      "click @ui.tweetContactButton": "tweetContactButtonClicked"
    },
    toggleAddRemove: function(e) {
      e.preventDefault();
      var $e = $(e.target);
      if (e.target.nodeName === 'I') $e = $e.parent();
      var $other = $e.siblings();
      $e.attr('disabled', 'disabled');
      $other.removeAttr('disabled');
    },
    tweetContactButtonClicked: function(e){
      e.preventDefault();
      var self = this;
      
      var view = Robin.layouts.main.saySomething.currentView;
      text = "Hey @@[Handle] here's a press release you might find interesting: @[Link]";
      text = text.replace('@[Handle]', self.model.get('screen_name'));
      text = text.replace('@[Link]', self.releaseModel.permalink);
      
      $('form.navbar-search-sm').hide();
      $('#shrink-links').prop('checked', true);
      $('#shrink-links').prop('disabled', true);
      $('#createPost').find('textarea').val(text);
      $('#createPost').show();
      $('.progressjs-progress').show();
      
      view.checkAbilityPosting();
      view.setCounter();
      e.stopPropagation();
    },
    addInfluencer: function(e) {
      this.toggleAddRemove(e);
      var current_model = this.pitchContactsCollection.findWhere({
        origin: 'twtrland',
        twitter_screen_name: this.model.get('screen_name')
      });
      
      if (current_model == null){
        var model = new Robin.Models.Contact({
          origin: 'twtrland',
          twitter_screen_name: this.model.get('screen_name'),
          first_name: this.model.get('firstName'),
          last_name: this.model.get('lastName'),
          outlet: "Twitter"
        });
        this.pitchContactsCollection.add(model);
      }
    },
    removeInfluencer: function(e) {
      this.toggleAddRemove(e);
      var model = this.pitchContactsCollection.findWhere({
        twitter_screen_name: this.model.get('screen_name'),
        origin: 'twtrland'
      });
      this.pitchContactsCollection.remove(model);
    },
    initialize: function(options) {
      this.pitchContactsCollection = options.pitchContactsCollection;
      this.releaseModel = options.releaseModel.toJSON().release;
    },
    templateHelpers: function(){
      return {
        pitchContactsCollection: this.pitchContactsCollection
      }
    }
  });


  ReleasesBlast.SocialTargetsCompositeView = Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/influencers/influencers',
    childView: ReleasesBlast.InfluencerView,
    childViewContainer: "tbody",
    ui: {
      tooltips: "[data-toggle=tooltip]"
    },
    childViewOptions: function() {
      return this.options;
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
      this.initTooltip();
    },
    initTooltip: function(){
      this.ui.tooltips.tooltip({
        html: true
      });
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
        dom: 'T<"clear">lfrtip',
        "oTableTools": {
          "aButtons": [
            {
              "sExtends": "text",
              "sButtonText": "Export as CSV",
              "bFooter": false,
              "fnClick": function ( nButton, oConfig, oFlash ) {
                if (Robin.user.get('can_export') == true) {
                  var order = table.order();
                  var csvContent = self.makeCsvData(order[0][0], order[0][1]);

                  openWindow('POST', '/export_influencers.csv', 
                    {items: csvContent});
                } else {
                  $.growl('Only Enterprise and Ultra users can have this feature.', {
                    type: "danger",
                  });
                }
                
              }
            }
          ]
        }
      });
    },
    makeCsvData: function(order_column, order_direction){
      var sorted_collection = _.sortBy(this.collection.models, function(item){
        var sort_value = parseInt(item.get('followers_count'));
        
        switch(order_column){
          case 0:
            sort_value = item.get('name');
            break;
          case 1:
            sort_value = parseInt(item.get('followers_count'));
            break;
          case 2:
            sort_value = item.get('reachScore');
            break;
          case 3:
            sort_value = item.get('ampScore');
            break;
          case 4:
            sort_value = item.get('relScore');
            break;
          case 5:
            sort_value = item.get('screen_name');
            break;
          default:
            sort_value = parseInt(item.get('followers_count'));
        }
        
        return sort_value;
      });
      
      if (order_direction == 'desc')
        sorted_collection = sorted_collection.reverse();
      
      var csvObject = [];
      csvObject.push(["Influencer", "Followers", "Reach", 
        "Amplification", "Relevance", "Contact"]); // CSV Headers
      
      _.each(sorted_collection, function(item){
        csvObject.push([item.get('name'), item.get('followers_count'), 
          item.get('reachScore'), item.get('ampScore'), item.get('relScore'),
          '@' + item.get('screen_name')]);
      });
      
      return JSON.stringify(csvObject);
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
});
