Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){
  ReleasesBlast.ContactModel = Backbone.Model.extend({
    urlRoot: "/share_by_email"
  });
  
  ReleasesBlast.ContactAuthorFormMessageView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/contact-author/contact-form-message',
    tagName: 'textarea',
    className: 'form-control',
    attributes: {
      'rows': '7'
    },
    initialize: function(options){
      this.authorModel = options.authorModel;
      this.sentencesNumber = options.sentencesNumber;
    },
    serializeData: function(){
      return {
        "author": this.authorModel,
        "summary": this.summary(),
        "release": this.model,
        "currentUser": Robin.currentUser
      }
    },
    summary: function(){
      var sentences = _(this.model.get('summaries')).first(this.sentencesNumber);
      return _(sentences).map(function(sentence){ 
        return "- " + sentence
      }).join('\n');
    }
  });
  
  ReleasesBlast.ContactAuthorFormView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/contact-author/contact-form',
    model: Robin.Models.Author,
    className: "modal-dialog",
    events: {
      "click #send-btn": "sendBtnClicked"
    },
    ui: {
      summarizeSlider: "#slider",
      formMessage: "#form-message",
      subjectInput: "[name=subject]",
      emailInput: "[name=email]"
    },
    templateHelpers: function(){
      return {
        currentUser: Robin.currentUser
      };
    },
    initialize: function(options){
      this.releaseModel = options.releaseModel;
      this.contactModel = new ReleasesBlast.ContactModel();
    },
    onShow: function(){
      this.initSlider();
      this.renderMessageTextarea(5);
    },
    initSlider: function(){
      var self = this;
      this.ui.summarizeSlider.slider({
        min: 1,
        max: 10,
        range: "min",
        value: 5,
        slide: function (event, ui) {
          $("#number-of-sentences span").text(ui.value);
          self.renderMessageTextarea(parseInt(ui.value));
        }
      });
    },
    renderMessageTextarea: function(sentencesNumber){
      var messageTextarea = new ReleasesBlast.ContactAuthorFormMessageView({
        model: this.releaseModel,
        authorModel: this.model,
        sentencesNumber: sentencesNumber
      });
      this.ui.formMessage.html(messageTextarea.render().el);
    },
    sendBtnClicked: function(event){
      this.sendEmail();
    },
    errorFields: {
      "subject": "Subject",
      "body": "Message",
      "sender": "Your email",
      "reciever": "Email target"
    },
    sendEmail: function(){
      var self = this;
      this.contactModel.set({
        subject: this.ui.subjectInput.val(),
        body: this.ui.formMessage.find('textarea').val(),
        sender: this.ui.emailInput.val(),
        reciever: this.model.get('email')
      });
      
      this.contactModel.save({}, {
        success: function(model, response, options){
          Robin.modal.empty();
        },
        error: function(model, response, options){
          _(response.responseJSON).each(function(val, key){
            $.growl({message: self.errorFields[key] + ' ' + val[0]
            },{
              type: 'danger'
            });
          });
        }
      });
    }
  });


  ReleasesBlast.AuthorInspectLayout = Marionette.LayoutView.extend({
    template: 'modules/releases_blast/templates/authors/author-inspect-layout',
    regions: {
      statsRegion: '#author-stats',
      recentStoriesRegion: '#author-recent-stories',
      relatedStoriesRegion: '#author-related-stories'
    },
    className: 'modal-dialog'
  });


  ReleasesBlast.AuthorView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/authors/_author',
    tagName: "tr",
    events: {
      "click .inspect":         "openInspectModal",
      "click a.btn-danger":     "removeAuthor",
      "click a.btn-success":    "addAuthor",
      "click a.contact-author": "openContactAuthorModal"
    },
    toggleAddRemove: function(e) {
      e.preventDefault();
      var $e = $(e.target);
      if (e.target.nodeName === 'I') $e = $e.parent();
      var $other = $e.siblings();
      $e.attr('disabled', 'disabled');
      $other.removeAttr('disabled');
    },
    addAuthor: function(e) {
      this.toggleAddRemove(e);
      var current_model = this.pitchContactsCollection.findWhere({
        author_id: this.model.get('id'),
        origin: 'pressr'
      });
      
      if (current_model == null) {
        var model = new Robin.Models.Contact({
          author_id: this.model.get('id'),
          origin: 'pressr',
          first_name: this.model.get('first_name'),
          last_name: this.model.get('last_name'),
          email: this.model.get('email'),
          outlet: this.model.get('blog_name')
        });
        this.pitchContactsCollection.add(model);
      }
    },
    removeAuthor: function(e) {
      this.toggleAddRemove(e);
      var model = this.pitchContactsCollection.findWhere({
        author_id: this.model.get('id'),
        origin: 'pressr'
      });
      this.pitchContactsCollection.remove(model);
    },
    initialize: function(options){
      this.pitchContactsCollection = options.pitchContactsCollection;
      this.releaseModel = options.releaseModel;
    },
    templateHelpers: function(){
      return {
        pitchContactsCollection: this.pitchContactsCollection
      }
    },
    openInspectModal: function(e){
      e.preventDefault();
      var self = this;
      
      var layout = new ReleasesBlast.AuthorInspectLayout({
        model: this.model
      });
      
      Robin.modal.show(layout);
      
      // Related stories
      var relatedStoriesCollection = new Robin.Collections.RelatedStories({
        author_id: this.model.get('id'),
        releaseModel: this.releaseModel
      });
      
      // Loading view
      layout.relatedStoriesRegion.show(
        new Robin.Components.Loading.LoadingView({
          className: 'stories-loading-container'
        })
      );
      
      relatedStoriesCollection.fetchStories({
        success: function(collection, data, response){
          var relatedStoriesView = new ReleasesBlast.StoriesList({
            collection: collection
          });
          layout.relatedStoriesRegion.show(relatedStoriesView);
        }
      });
      // END Related stories
      
      
      // Recent stories
      var recentStoriesCollection = new Robin.Collections.RecentStories({
        author_id: this.model.get('id'),
        releaseModel: this.releaseModel
      });
      
      // Loading view
      layout.recentStoriesRegion.show(
        new Robin.Components.Loading.LoadingView({
          className: 'stories-loading-container'
        })
      );
      
      recentStoriesCollection.fetchStories({
        success: function(collection, data, response){
          var recentStoriesView = new ReleasesBlast.StoriesList({
            collection: collection
          });
          layout.recentStoriesRegion.show(recentStoriesView);
        }
      });
      // END Recent stories
      
      // Author stats
      var authorStatsModel = new Robin.Models.AuthorStats({ id: this.model.id });
      
      // Loading view
      layout.statsRegion.show(
        new Robin.Components.Loading.LoadingView()
      );
      
      authorStatsModel.fetch({
        success: function(model, response, options){
          var authorStatItemView = new ReleasesBlast.AuthorStatsView({
            model: model,
            authorModel: self.model,
            releaseModel: self.releaseModel
          });
          layout.statsRegion.show(authorStatItemView);
        }
      });
      // END Author stats
    },
    openContactAuthorModal: function(e){
      e.preventDefault();
      
      var contactAuthorFormView = new ReleasesBlast.ContactAuthorFormView({
        model: this.model,
        releaseModel: this.releaseModel
      });
      
      Robin.modal.show(contactAuthorFormView);
    },
    wordMapper: function(word_count){
      if (word_count <= 150){
        return {label: "Very Short", tooltip: "<strong>150</strong> words or less"};
      }

      if (word_count < 520 && word_count > 150){
        return {
          label: "Short", 
          tooltip: "Between <strong>150</strong> and <strong>520</strong> words"
        };
      }

      if (word_count < 990 && word_count > 520){
        return {
          label: "Average", 
          tooltip: "Between <strong>520</strong> and <strong>990</strong> words"
        };
      }

      if (word_count < 1940 && word_count > 990){
        return {
          label: "Semi-long", 
          tooltip: "Between <strong>990</strong> and <strong>1940</strong> words"
        };
      }

      if (word_count < 4910 && word_count > 1940){
        return {
          label: "Long", 
          tooltip: "Between <strong>1940</strong> and <strong>4910</strong> words"
        };
      }

      if (word_count >= 4910){
        return {
          label: "Very long", 
          tooltip: "<strong>4910</strong> words or more"
        };
      }

      return "Not defined";
    }
  });


  ReleasesBlast.AuthorsCompositeView = Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/authors/authors',
    childView: ReleasesBlast.AuthorView,
    childViewContainer: "tbody",
    collection: Robin.Collections.Authors,
    childViewOptions: function() {
      return this.options;
    },
    onRender: function() {
      this.initDataTable();
      this.scrollToView();
    },
    initDataTable: function(){
      this.$el.find('table').DataTable({
        "info": false,
        "searching": false,
        "lengthChange": false,
        "ordering": false,
        "pageLength": 25,
        "bAutoWidth" :false,
        "columns": [
          { "width": "30%" },
          null,
          null,
          null
        ]
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


  ReleasesBlast.BlogTargetsCompositeView = Marionette.CompositeView.extend({
    template: 'modules/releases_blast/templates/authors/blog-targets',
    childView: ReleasesBlast.AuthorView,
    childViewContainer: "tbody",
    collection: Robin.Collections.SuggestedAuthors,
    childViewOptions: function() {
      return this.options;
    },
    onRender: function() {
      this.initDataTable();
    },
    initDataTable: function(){
      this.$el.find('table').DataTable({
        "info": false,
        "searching": false,
        "lengthChange": false,
        "ordering": false,
        "pageLength": 25,
        "bAutoWidth" :false,
        "columns": [
          { "width": "30%" },
          null,
          null,
          null,
          null
        ]
      });
    }
  });
});
