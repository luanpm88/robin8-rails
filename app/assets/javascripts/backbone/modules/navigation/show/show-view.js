Robin.module('Navigation.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.NavigationView = Backbone.Marionette.ItemView.extend({
    getTemplate: App.template('modules/navigation/show/templates/navigation')

    // Checks if there are no recommendations and then adds to the nav
    onRender :function(){

        var lastSignInAt = Robin.currentUser.attributes.updated_at;
        var id = Robin.currentUser.attributes.id;
        var statusUrl = "/recommendations/status/" + id + ".json?last_sign_in_at=" + lastSignInAt;

        $.get( statusUrl, function( data ) {
            if(data.new_recommendations > 0) {
                $("#no-new-recommendations").hide();
                $("#new-recommendations-badge").text(data.new_recommendations);
                $("#new-recommendations").show();
            }
        });
    }

  });

});
