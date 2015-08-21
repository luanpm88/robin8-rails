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
      influencersSearch: '#find-influencers button',
      authorsKeywordsInput: '#find-authors [name=keywords]',
      authorsContactNameInput: '#find-authors [name=contact_name]',
      authorsOutletInput: '#find-authors [name=outlet]',
      authorsLocationInput: '#find-authors [name=location]',
      influencersTopicsInput: '#find-influencers [name=topics]',
      influencersLocationInput: '#find-influencers [name=location]'
    },
    events: {
      'switchChange.bootstrapSwitch @ui.checkbox': 'changeFinder',
      'click @ui.authorsSearch': 'searchAuthors',
      'click @ui.influencersSearch': 'searchInfluencers'
    },
    onShow: function(){
      this.initSwitch();
      this.initSelect2();
      this.initGeoAutocomplete();
      this.on("authors:select", this.authorsSelect);
      this.on("influencers:select", this.influencersSelect);
    },
    initSwitch: function(){
      this.ui.checkbox.bootstrapSwitch({
        size: 'mini',
        onColor: "info",
        offColor: "info",
        onText: polyglot.t("smart_release.targets_step.search_tab.search_authors.authors"),
        offText: polyglot.t("smart_release.targets_step.search_tab.search_influencers.influencers")
      });
    },
    initGeoAutocomplete: function(){
      this.ui.authorsLocationInput.geocomplete();
    },
    initSelect2: function(){
      this.ui.authorsKeywordsInput.select2({
        tags: [],
      });
      
      this.ui.influencersTopicsInput.select2({
        placeholder: "Topics",
        multiple: true,
        formatResult: function (object, container, query) {
          return object.text;
        },
        formatSelection: function (object, container) {
          return object.text;
        },
        id: function (object) {
          return object.id;
        },
        ajax: {
          url: '/autocompletes/skills',
          dataType: "JSON",
          data: function (term, page) {
            return {
              term: term
            };
          },
          results: function (data, page) {
            return { 
              results: _(data.skills).map(function(item) {
                return { id: item['id'], text: item['name'] }; 
              })
            };
          }
        },
        minimumInputLength: 1,
        createSearchChoice: function () { return null }
      });
      
      this.ui.influencersLocationInput.select2({
        placeholder: "Locations",
        multiple: false,
        formatInputTooShort: function (input, min) { var n = min - input.length; return polyglot.t("select2.too_short", {count: n}); },
        formatNoMatches: function () { return polyglot.t("select2.not_found"); },
        formatSearching: function () { return polyglot.t("select2.searching"); },
        formatResult: function (object, container, query) {
          return object.text;
        },
        formatSelection: function (object, container) {
          return object.text.split(',')[0];
        },
        id: function (object) {
          return object.id.split(',')[0];
        },
        ajax: {
          url: "/autocompletes/locations",
          dataType: "JSON",
          data: function (term, page) {
            return {
              term: term
            };
          },
          results: function (data, page) {
            return {
              results: _(data.locations).map(function (item) {
                return { id: item['id'], text: item['name'] };
              })
            }
          }
        },
        minimumInputLength: 2,
        createSearchChoice: function () { return null }
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
      this.changeTitle(" " + polyglot.t("smart_release.targets_step.search_tab.search_authors.title"));
      this.ui.authorsForm.removeClass('hide');
      this.ui.influencersForm.addClass('hide');
    },
    influencersSelect: function(){
      this.changeTitle(" " + polyglot.t("smart_release.targets_step.search_tab.search_influencers.title"));
      this.ui.authorsForm.addClass('hide');
      this.ui.influencersForm.removeClass('hide');
    },
    searchAuthors: function(event){
      event.preventDefault();
      
      var params = {};
      params['keywords'] = this.ui.authorsKeywordsInput.select2('val');
      params['contactName'] = this.ui.authorsContactNameInput.val();
      params['outlet'] = this.ui.authorsOutletInput.val();
      params['location'] = this.ui.authorsLocationInput.val();
      
      Robin.vent.trigger("search:authors:clicked", params);
    },
    searchInfluencers: function(event){
      event.preventDefault();
      
      var params = {};
      params['topics'] = this.ui.influencersTopicsInput.select2('val');
      params['location'] = this.ui.influencersLocationInput.select2('val');
      params['typecast'] = this.ui.influencersForm.find('[type=radio]:checked').val();
      
      Robin.vent.trigger("search:influencers:clicked", params);
    }
  });
});
