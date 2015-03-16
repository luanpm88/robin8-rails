Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.StoryItemView = Backbone.Marionette.ItemView.extend({
    template: 'modules/monitoring/show/templates/monitoring_story',
    tagName: "li",

    events: {
      'click .js-open-story': 'openStory',
      'click .share': 'shareStory',
    },

    modelEvents: {
      change: 'render'
    },

    onRender: function() {
      var shares = this.model.attributes.shares_count;

      if(this.model.get('isNew')) {
        this.$el.addClass('hidden');
      } else {
        this.$el.removeClass('hidden');
      };

      if (this.$el.find('img.image').css('display') == 'none') {
        this.$el.find('img.image').attr('src', '/assets/news.png');
      }

      if(shares) {
        this.$el.find('.likes').tooltip({
          title: JST['backbone/modules/monitoring/show/templates/shares_tooltip'](shares),
          trigger: 'hover',
          placement: 'right',
          html: true
        });
      }

      this.$el.find('[data-toggle=tooltip]').tooltip({trigger:'hover'});
      this.$el.find('.stream-body').height($(window).height() - 90 - 12);
      this.$el.find('.js-story-img').nailthumb({width: 64, height: 64});
    },
    openStory: function() {
      var win = window.open(this.model.attributes.link, '_blank');
      win.focus();
    },

    shareStory: function(e) {
      var view = Robin.layouts.main.saySomething.currentView;
      var model = this.model;
      var title = model.attributes.title.length > 110 ? model.attributes.title.substring(0, 105) + '...' : model.attributes.title
      var text = title + ' | ' + model.attributes.link;
      
      BitlyClient.shorten(model.attributes.link, function(data) {
        text = title + ' | ' + _.values(data.results)[0].shortUrl;
        $('form.navbar-search-sm').hide();
        $('#shrink-links').prop('checked', true);
        $('#shrink-links').prop('disabled', true);
        $('#createPost').find('textarea').val(text);
        $('#createPost').show();
        $('.progressjs-progress').show();
        
        view.checkAbilityPosting();
        view.setCounter();
        e.stopPropagation();
      });
    },
  });

});
