Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.StoryItemView = Backbone.Marionette.ItemView.extend({
    template: 'modules/monitoring/show/templates/monitoring_story',
    tagName: "li",
    events: {
      'click .js-open-story': 'openStory',
    },
    onRender: function() {
      var shares = this.model.attributes.shares_count;
      if(shares) {
        this.$el.find('.likes').tooltip({
          title: '<i class="fa fa-facebook-square"></i> ' + shares.facebook + ' \
                  <i class="fa fa-twitter-square"></i> ' + shares.twitter + ' \
                  <i class="fa fa-google-plus-square"></i> ' + shares.google_plus,
          trigger: 'hover',
          placement: 'right',
          html: true
        });
      }

      this.$el.find('[data-toggle=tooltip]').tooltip({trigger:'hover'});
      this.$el.find('.stream-body').height($(window).height() - 90 - 12);
    },
    openStory: function() {
      var win = window.open(this.model.attributes.link, '_blank');
      win.focus();
    }
  });

});
