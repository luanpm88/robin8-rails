Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.SearchLayout = Marionette.LayoutView.extend({
    template: 'modules/releases_blast/templates/search-targets/search-layout',
    regions: {
      searchCriteriaRegion: "#search-criteria",
      searchResultRegion: "#search-result"
    }
  });
  
  ReleasesBlast.SearchCriteriaView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/search-targets/search-criteria',
    tagName: "div",
    className: "panel panel-success",
    ui: {
      checkbox: '[type="checkbox"]',
      authorsForm: '#find-authors',
      influencersForm: '#find-influencers',
      title: '.panel-title strong',
      authorsSearch: '#find-authors button',
      influencersSearch: '#find-influencers button'
    },
    events: {
      'switchChange.bootstrapSwitch @ui.checkbox': 'changeFinder',
      'click @ui.authorsSearch': 'searchAuthors',
      'click @ui.influencersSearch': 'searchInfluencers'
    },
    onShow: function(){
      this.initSwitch();
      this.on("authors:select", this.authorsSelect);
      this.on("influencers:select", this.influencersSelect);
    },
    initSwitch: function(){
      this.ui.checkbox.bootstrapSwitch({
        size: 'mini',
        onColor: "info",
        offColor: "info",
        onText: "Authors",
        offText: "Influencers"
      });
    },
    changeFinder: function(event, state){
      if (state)
        this.trigger('authors:select')
      else
        this.trigger('influencers:select')
    },
    changeTitle: function(text){
      this.ui.title.text(text);
    },
    authorsSelect: function(){
      this.changeTitle(" Search Authors");
      this.ui.authorsForm.removeClass('hide');
      this.ui.influencersForm.addClass('hide');
    },
    influencersSelect: function(){
      this.changeTitle(" Search Influencers");
      this.ui.authorsForm.addClass('hide');
      this.ui.influencersForm.removeClass('hide');
    },
    searchAuthors: function(){
      console.log("Author button clicked!");
    },
    searchInfluencers: function(){
      console.log("Influencers button clicked!");
    }
  });
});
