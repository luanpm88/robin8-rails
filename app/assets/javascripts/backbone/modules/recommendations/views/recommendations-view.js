Robin.module('Recommendations', function(Recommendations, App, Backbone, Marionette, $, _){

  Recommendations.ItemView = Marionette.ItemView.extend({
    template: 'modules/recommendations/templates/recommendation',
    model: Robin.Models.Recommendation,
    className: 'recommendation',
    tagName: "div",

    initialize: function() {
        this.listenTo(this.model, "change", this.render);
    },

    events: {
        'click #like-content': 'likeContent',
        'click #dislike-content': 'dislikeContent',
        'click #share-content': 'shareContent',
        'click #view-content': 'viewContent'
    },

    onRender: function() {
      $(this.el).find(".recommendation-body" ).hover(
        function() {
            var overlayId = "#" + $(this).attr('id') + "-overlay";
            $(overlayId).show();
        }, function() {
             var overlayId = "#" + $(this).attr('id') + "-overlay";
             $(overlayId).hide();
        });
    },

    likeContent: function(e) {
        e.preventDefault();
        Robin.vent.trigger("LikeContent", this.model);
    },

    dislikeContent: function(e) {
        e.preventDefault();
        Robin.vent.trigger("DislikeContent", this.model);
    },

    shareContent: function(e) {
        e.preventDefault();

        var view = Robin.layouts.main.saySomething.currentView;
        var model = this.model;
        var title = model.attributes.title.length > 110 ? model.attributes.title.substring(0, 105) + '...' : model.attributes.title
        var text = title + ' | ' + model.attributes.link;
        
        BitlyClient.shorten(model.attributes.link, function(data) {
          text = title + ' | ' + _.values(data.results)[0].shortUrl;
          $('form.navbar-search-sm').hide();
          $('#shrink-links').prop('checked', true);
          $('.icheckbox_square-blue').addClass('checked')
          $('#createPost').find('textarea').val(text);
          $('#createPost').show();
          $('.progressjs-progress').show();
          
          view.checkAbilityPosting();
          view.setCounter();
          e.stopPropagation();
        });

        Robin.vent.trigger("ShareContent", this.model);
    },

    viewContent: function(e) {
        e.preventDefault();
        var id = "#" + e.currentTarget.parentElement.id
        $(this.el).find(id).hide();
        window.open(this.model.attributes.link, '_blank');
        Robin.vent.trigger("ViewContent", this.model);
    }
    
  });

  Recommendations.CollectionView = Marionette.CollectionView.extend({
    childView: Recommendations.ItemView,
    collection: Robin.Collections.Recommendations,
    className: 'recommendations',
    tagName: "div",

    onRender: function(){
        var self = this;
        var page = self.collection.page; 
        var recommendationType = self.collection.recommendationType; 
        var pages = 7;

        $('#no-more-recommendations').hide();
        if(page == 0){$('.more-recommendations').remove();}
        if(recommendationType == "BOTH"){pages = 13};

        //Implements Endless Page
        if($('#more-recommendations').is(':visible')){$('#more-recommendations').hide();}
        $(this.el).find('.recommendation-image').nailthumb({width: 300, height: 200});

        if(page < pages){
          $(window).scroll(function(){
              if($(window).scrollTop() + $(window).height() == $(document).height()) {
                $(window).unbind('scroll');

                var pageTurner = self.collection.page + 1;
                var currentRecommendationType = self.collection.recommendationType;

                if($('#more-recommendations').not(':visible')){$('#more-recommendations').show();}
                $("#more-recommendation-row").before("<div id='more-recommendations-container-" + pageTurner + "' class='more-recommendations'></div>");  
              
                Robin.vent.trigger("GetNextPage", pageTurner, currentRecommendationType);
              }
          });
        }else{
          $('#no-more-recommendations').show();
        }
    }
  });

  Recommendations.NoRecommendationsView = Marionette.CompositeView.extend({
    template: 'modules/recommendations/templates/no-recommendations',
    onRender: function(){
        //remove pages from endless page
        $('.more-recommendations').remove();
        $('#no-more-recommendations').hide();
    }

  });


  Recommendations.LoadingView = Marionette.CompositeView.extend({
    template: 'modules/recommendations/templates/loading',
    className: 'recommendations-loading-container',
    onShow: function(){
      var opts = this._getOptions();
      this.$el.spin(opts);
    },
    onClose: function(){
      this.$el.spin(false);
    },
    _getOptions: function(){
      lines: 10 // The number of lines to draw
      length: 6 // The length of each line
      width: 2.5 // The line thickness
      radius: 7 // The radius of the inner circle
      corners: 1 // Corner roundness (0..1)
      rotate: 9 // The rotation offset
      direction: 1 // 1: clockwise, -1: counterclockwise
      color: '#000' // #rgb or #rrggbb
      speed: 1 // Rounds per second
      trail: 60 // Afterglow percentage
      shadow: false // Whether to render a shadow
      hwaccel: true // Whether to use hardware acceleration
      className: 'spinner' // The CSS class to assign to the spinner
      zIndex: 2e9 // The z-index (defaults to 2000000000)
      top: '0' // Top position relative to parent in px
      left: '0' // Left position relative to parent in px
    }
  });

  Recommendations.RecommendationsNavView = Marionette.CompositeView.extend({
     template: 'modules/recommendations/templates/recommendations-nav',
     events: {
        'click #content-recommendations': 'getContentRecommendations',
        'click #influence-recommendations': 'getInfluenceRecommendations',
        'click #both-recommendations': 'getBothRecommendations'
      },

      getContentRecommendations: function(e) {
        e.preventDefault();
        $(".rec-nav").removeClass("active");
        $("#content-recommendations").addClass("active");
        Robin.vent.trigger("GetContentRecommendations");
      },

      getInfluenceRecommendations: function(e) {
        e.preventDefault();   
        $(".rec-nav").removeClass("active");
        $("#influence-recommendations").addClass("active");
        Robin.vent.trigger("GetInfluenceRecommendations");
      },

      getBothRecommendations: function(e) {
        e.preventDefault();
        $(".rec-nav").removeClass("active");
        $("#both-recommendations").addClass("active");
        Robin.vent.trigger("GetBothRecommendations");
      }
  });

  Recommendations.NewRecommendationsView = Marionette.CompositeView.extend({
    template: 'modules/recommendations/templates/new-recommendations',
    
    events: {
      'click #insert-user-tastes': 'InsertUserTastes',
      'click #btn-twitter': 'connectProfile'
    },

    connectProfile: function(e) {
      e.preventDefault();

      if ($(e.target).children().length != 0) {
        var provider = $(e.target).attr('name');
      } else {
        var provider = $(e.target).parent().attr('name');
      };

      console.log("Social Connect");

      var currentView = this;

      var url = '/users/auth/' + provider,
      params = 'location=0,status=0,width=800,height=600';
      currentView.connect_window = window.open(url, "connect_window", params);

      currentView.interval = window.setInterval((function() {
        if (currentView.connect_window.closed) {
          $.get( "/users/get_identities", function( data ) {
            Robin.identities = data;

            console.log(Robin.identities);
            
            // Robin.setIdentities(data);
            //currentView.render();

            // Robin.module("Social").postsView.render();
            // Robin.module("Social").tomorrowPostsView.render();
            // Robin.module("Social").othersPostsView.render();
            // Robin.SaySomething.Say.Controller.showSayView();
            window.clearInterval(currentView.interval);
          });
        }
      }), 500);
    },

    disconnect: function(e) {
      e.preventDefault();
      disconnectSocial($(e.target).attr('identityid'), this);
    },

    onRender: function() {

      Robin.currentUser.attributes["topics"] = "";

      $(this.el).find('#topics-select').select2({
        multiple: true,
        tags: true,
        minimumInputLength: 1,
        ajax: {
          url: '/autocompletes/topics',
          dataType: 'json',
          data: function(term, page) { 
            return { term: term } 
          },
          results: function(data, page) { 
            return { results: data }; 
          }
        }
      });

    },

    InsertUserTastes: function(e) {
      e.preventDefault();
      var topics = $("#topics-select").val();
      var category = $('#category-select').val();
      Robin.vent.trigger("InsertUserTastes", topics, category);
    }

  });

  

});
