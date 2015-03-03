Robin.module('NewsRoomPublic', function(NewsRoomPublic, App, Backbone, Marionette, $, _){

  NewsRoomPublic.FollowView = Marionette.ItemView.extend({
    template: 'modules/news-room-public/templates/follow',

    events: {
      'click #subscribe': 'subscribe'
    },

    subscribe: function(e) {
      e.preventDefault();

      var data = {
        list: $('#list').val(),
        email: $('#follower_email').val(),
      };

      $.ajax({
        type: 'POST',
        url: '/followers/add',
        data: data,
        datatype: 'json',
        success: function(){
          $('#list').val('');
          $('#follower_email').val('');
        }
      })
    }

  });

});
