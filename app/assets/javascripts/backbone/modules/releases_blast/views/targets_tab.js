Robin.module('ReleasesBlast', function(ReleasesBlast, App, Backbone, Marionette, $, _){

  ReleasesBlast.TargetsTabView = Marionette.ItemView.extend({
    template: 'modules/releases_blast/templates/targets-tab',
    className: 'row',
    events: {
      "click #next-step": "openPitchTab"
    },
    initialize: function(){
      this.on("suggested_authors:ready", this.render);
      this.on("social_targets:ready", this.renderSocialTargets)
      this.getSuggestedAuthors();
      this.getSocialTargets();
      this.suggestedAuthors = {};
      this.influencers = {};
    },
    onRender: function () {
      // Get rid of that pesky wrapping-div.
      // Assumes 1 child element present in template.
      this.$el = this.$el.children();
      // Unwrap the element to prevent infinitely 
      // nesting elements during re-render.
      this.$el.unwrap();
      this.setElement(this.$el);
      this.$el.find('#targets-blogs table').DataTable({
        "info": false,
        "searching": false,
        "lengthChange": false,
        "ordering": false,
        "columns": [
          { "width": "30%" },
          { "width": "25%" },
          { "width": "15%" },
          { "width": "10%" },
          { "width": "10%" },
          { "width": "2%" },
        ]
      });
    },
    templateHelpers: function(){
      return {
        suggestedAuthors: this.suggestedAuthors
      }
    },
    openPitchTab: function(){
      ReleasesBlast.controller.pitch();
    },
    getSuggestedAuthors: function(){
      var that = this;
      
      $.ajax({
        url: 'robin8_api/suggested_authors',
        dataType: 'json',
        method: 'POST',
        data: {
          title: that.model.attributes.title, 
          body: that.model.attributes.text,
          per_page: 50
        },
        success: function(response){
          that.suggestedAuthors = response;
          that.trigger("suggested_authors:ready");
        }
      });
    },
    getSocialTargets: function(){
      var that = this;
      
      var skills = _.chain(that.model.attributes.iptc_categories).map(function(i){
        return that.mapIptcCategoryToTwtrland(i);
      }).uniq().value();
      
      
      $.ajax({
        url: 'robin8_api/influencers',
        dataType: 'json',
        method: 'GET',
        data: {
          "skills[]": skills
        },
        success: function(response){
          that.influencers = response.influencers;
          that.trigger("social_targets:ready");
        }
      });
    },
    renderSocialTargets: function(){
      var social_targets_view = new ReleasesBlast.SocialTargetsView({
        influencers: this.influencers
      });
      this.$el.find("#targets-social").html(social_targets_view.render().el.innerHTML);
    },
    mapIptcCategoryToTwtrland: function(code) {
      var category = null;

      if (code.trim().length > 0) {
        var level1 = code.substring(0, 2);
        var level2 = code.substring(2, 5);
        var level3 = code.substring(5);

        switch (level1) {
          case "01":
            if (level2 === "002")
              category = "Architecture";
            else if (level2 === "004")
              category = "Festivals";
            else if (level2 === "005")
              category = "Cinema";
            else if (level2 === "007")
              category = "Fashion";
            else if (level2 === "011")
              category = "Music";
            else if (/016|023/.test(level2))
              category = "Entertainment";
            else if (level2 === "017")
              category = "Theatre";
            else if (level2 === "020")
              category = "Arts";
            else if (level2 === "021")
              category = "Entertainment";
            else if (level2 === "022")
              category = "Culture";
            else if (level2 === "025")
              category = "Film";
            else if (level2 === "026")
              category = "Media";
            break;
          case "02":
            if (/001|010/.test(level2))
              category = "Crime";
          case "03":
            if (level2 === "010")
              category = "Transportation";
            else if (level2 === "015")
              category = "Breaking News";
            break;
          case "04":
            if (level2 === "003")
              if (level3 === "005")
                category = "Software";
              else
                category = "Computers";
              else if (level2 === "008")
                category = "Economics";
              else if (level2 === "009")
                category = "Stocks";
              else if (level2 === "010")
                category = "Media";
              else if (level2 === "012")
                category = "Environments";
              else if (level2 === "014")
                category = "Tourism";
              else if (level2 === "015")
                category = "Transportation";
              else if (code === "04016029")
                category = "Marketing";
              else if (level2 === "018")
                category = "Business";
              break;
          case "06":
            if (level2 === "010")
              category = "Environments";
            break;
          case "07":
            if (code === "07003001")
              category = "Prescription Drugs";
            else if (code === "07003003")
              category = "Weight Loss";
            else if (/004|005/.test(level2))
              category = "Health";
            else if (level2 === "016")
              category = "Fitness";
            break;
          case "08":
            if (code == "08003002")
              category = "Celebrities";
            break;
          case "10":
            if (level2 === "001")
              category = "Video Games";
            else if (code === "10004001")
              category = "DIY";
            else if (code === "10004002")
              category = "Shopping";
            else if (level2 === "005")
              category = "Travel";
            else if (level2 === "006")
              category = "Tourism";
            else if (level2 === "014")
              category = "Auto";
            else if (level2 === "016")
              category = "Beauty";
            break;
          case "11":
            if (code === "11001002")
              category = "National Security";
            else if (/11003002|11002003|11003005/.test(code) || level2 === "010")
              category = "Politics";
            else if (code === "11003004")
              category = "Elections";
            break;
          case "12":
            if (level2 === "001")
              category = "Culture";
            break;
          case "13":
            if (code === "13003002")
              category = "History";
            else if (level2 == "012")
              category = "Economy";
            break;
          case "14":
            if (code === "14006001")
              category = "Parenting";
            else if (level2 == "012")
              category = "Economy";
            break;
          case "15":
            if (level2 === "003")
              category = "NFL";
            else if (level2 === "007")
              category = "Baseball";
            else if (level2 === "008")
              category = "Basketball";
            else if (level2 === "015")
              category = "Kayak";
            else if (level2 === "027")
              category = "Golf";
            else if (level2 === "031")
              category = "Hockey";
            else if (level2 === "053")
              category = "Snowboarding";
            else if (level2 === "073")
              if (level3 === "002")
                category = "Winter Sports"
              else if (level3 === "018")
                category = "Soccer";
              else if (level3 === "046")
                category = "NFL";
            break;
          case "16":
            if (level2 === "009")
              category = "Breaking News";
            else if (level2 === "011")
              category = "Crisis";
          default:
            category = null;
            break;
        }
      }
      
      if (category === null) {
          var mono_cat = this.mapIptcCategoryToMononewsCat(code);

          switch (mono_cat) {
              case "Arts & Entertainment":
                  category = "Arts";
                  break;
              case "Beauty & Fashion":
                  category = "Fashion";
                  break;
              case "Games":
                  category = "Video Games";
                  break;
              case "Green":
                  category = "Environments";
                  break;
              case "Health & Fitness":
                  category = "Health";
                  break;
              case "Home & Garden":
                  category = "Housekeeping";
                  break;
              case "Tech":
                  category = "Technology";
                  break;
              default:
                  category = mono_cat;
                  break;
          }
      }

      return category;
    },
    mapIptcCategoryToMononewsCat: function(code) {
        var category = "Lifestyle";

        if (code.trim().length > 0) {
            var level1 = code.substring(0, 2);
            var level2 = code.substring(2, 5);
            var level3 = code.substring(5);

            switch (level1) {
                case "01":
                    if (level2 == "004")
                        category = "Lifestyle";
                    else if (level2 == "007")
                        category = "Beauty & Fashion";
                    else if (/009|018/.test(level2))
                        category = "Travel";
                    else
                        category = "Arts & Entertainment";
                    break;
                case "03":
                    if (/001|002|005|008|009/.test(level2))
                        category = "Green";
                    else if (level2 == "010")
                        category = "Transportation";
                    else
                        category = "Lifestyle";
                    break;
                case "04":
                    if (/001|005|012/.test(level2))
                        category = "Green";
                    else if (/003|011/.test(level2))
                        category = "Tech";
                    else if (level2 == "010")
                        category = "Arts & Entertainment";
                    else if (level2 == "014")
                        category = "Travel";
                    else if (level2 == "015")
                        category = "Transportation";
                    else
                        category = "Business";
                    break;
                case "06":
                    if (/002|005|010/.test(level2) || (level2 == "006" && /002|003|006/.test(level3)))
                        category = "Green";
                    else
                        category = "Lifestyle";
                    break;
                case "07":
                    if (code == "07003003")
                        category = "Food";
                    else
                        category = "Health & Fitness";
                    break;
                case "08":
                    if (code == "08003002")
                        category = "Arts & Entertainment";
                    else
                        category = "Lifestyle";
                    break;
                case "10":
                    if (/001|002/.test(level2))
                        category = "Games";
                    else if (code == "10004001")
                        category = "Home & Garden";
                    else if (/005|006/.test(level2))
                        category = "Travel";
                    else if (level2 == "010")
                        category = "Arts & Entertainment";
                    else if (level2 == "013")
                        category = "Sports";
                    else if (level2 == "014")
                        category = "Transportation";
                    else if (level2 == "016")
                        category = "Beauty & Fashion";
                    else
                        category = "Lifestyle";
                    break;
                case "12":
                    if (code == "12023001")
                        category = "Arts & Entertainment";
                    else
                        category = "Lifestyle";
                    break;
                case "13":
                    if (code == "13003001")
                        category = "Lifestyle";
                    else if (code == "13003003")
                        category = "Health & Fitness";
                    else if (code == "13004001")
                        category = "Green";
                    else if (/001|002|003|004|005|006|007|008|009|010|012|013|014|015|016|017|018|019|020|021|022|023/.test(level2))
                        category = "Tech";
                    else
                        category = "Lifestyle";
                    break;
                case "14":
                    if (level2 == "002")
                        category = "Philanthropy";
                    else if (level2 == "006")
                        category = "Lifestyle";
                    else if (level2 == "008")
                        category = "Health & Fitness";
                    else if (level2 == "011")
                        category = "Arts & Entertainment";
                    else
                        category = "Lifestyle";
                    break;
                case "15":
                    category = "Sports";
                    break;
                default:
                    category = "Lifestyle";
                    break;
            }
        }
        else {
            category = "Lifestyle";
        }

        return category;
    }
  });
});
