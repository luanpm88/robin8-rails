Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.FollowView = Marionette.ItemView.extend({
    template: 'modules/news-room-public/templates/follow',

    events: {
      'click #subscribe': 'subscribe'
    },

    subscribe: function(e) {
      e.preventDefault();

      var data = {
        mailing_type: $('#mailing_type').val(),
        email: $('#follower_email').val(),
      };

      $.ajax({
        type: 'POST',
        url: '/users/follow',
        data: data,
        datatype: 'json',
        success: function(){
          $('#mailing_type').val('');
          $('#follower_email').val('');
        }
      })
    }

  });

});
