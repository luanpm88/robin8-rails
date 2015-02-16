Robin.module('Monitoring.Show', function(Show, App, Backbone, Marionette, $, _){
  Show.MonitoringPage = Backbone.Marionette.LayoutView.extend({
    template: 'modules/monitoring/show/templates/monitoring',

    events: {
      'click #add-stream': 'addStream',
    },

    regions: {
      streams: ".stream-container",
    },

    initialize: function() {
    },

    addStream: function() {
      var monitoringStreamView = new Show.MonitoringStreamView();
      $(this.getRegion('streams').el).append(monitoringStreamView.render().el);
    },

    onRender: function() {

      // $addStreamBtn = this.$el.find('#add-stream');

      // $addStreamBtn.tooltip({title: 'Add Stream', trigger: 'hover', placement: 'left'});
      // $addStreamBtn.on('click', function(){
      //   $('.stream-container').append(getStream());
      //   $('.stream-body').height($(window).height() - 90 - 12);
      // });

      // function getStream(){
      //   var html = JST['backbone/modules/monitoring/show/templates/monitoring_stream'](
      //     {
      //       title: chance.pick(['Apple Inc.', 'Microsoft', 'MyPRGenie', 'AYLIEN', 'Technology', 'Hardware', 'Labor']),
      //       updates: chance.natural({min: 1, max: 10})
      //     }
      //   );
      //   var html = $(html);
      //   html.find('.sort-by select').on('change', function(){
      //     var val = $(this).val();
      //     if(val == "2") {
      //       html.find('.stream-settings .time-range').show();
      //       html.find('.stream-settings').addClass('expand');
      //     } else if(val == "1") {
      //       html.find('.stream-settings .time-range').hide();
      //       html.find('.stream-settings').removeClass('expand');
      //     }
      //   });
      //   _(_.range( chance.natural({min: 8, max: 15}) )).each(function(i){
      //     html.find(".stories").append(JST['backbone/modules/monitoring/show/templates/monitoring_story'](
      //       {
      //         name: chance.name(),
      //         text: chance.sentence({words: 9}),
      //         timeago: chance.natural({min: 1, max: 24}),
      //         likes: chance.natural({min: 5, max: 347})
      //       }
      //     ));
      //   });
      //   return html;
      // }

      // _(_.range(chance.natural({min: 2, max: 4}))).each(function(i){
      //   $(".stream-container").append(getStream());
      // });

      // $(".stream-container").sortable({
      //   handle: '.stream-header'
      // });
      // $(".stream-container").disableSelection();

      // $('.delete-stream').on('click', function(){
      //   swal({
      //     title: "Delete Stream?",
      //     text: "You will not be able to recover this stream.",
      //     type: "error",
      //     showCancelButton: true,
      //     confirmButtonClass: 'btn-danger',
      //     confirmButtonText: 'Delete'
      //   });
      // });

      // $('.settings-button').on('click', function(){
      //   $(this).parent().parent().find('.slider').toggleClass('closed');
      // });

      // $('.likes').tooltip({title: '<i class="fa fa-facebook-square"></i> 35 <i class="fa fa-twitter-square"></i> 17 <i class="fa fa-google-plus-square"></i> 5', trigger: 'hover', placement: 'right', html: true});
      // $('[data-toggle=tooltip]').tooltip({trigger:'hover'});
      // $('.stream-body').height($(window).height() - 90 - 12);
    },
  });
});