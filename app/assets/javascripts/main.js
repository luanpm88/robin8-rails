// Utils
window.capitalize = function(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

window.clipText = function(string, length) {
  return (string.length > length) ? string.substring(0,length-3) + '...' : string;
}

$(function(){
  var inits = {};

  // Navigation
  $('#sidebar li a').on('click', function() {
    $('#sidebar li.active').removeClass('active');
    $(this).parent().addClass('active');
    var tab = $(this).attr('id').replace('nav-','');
    $('.page-content').html(_.template($('#_'+tab).text(),{}));
    if(inits[tab]) inits[tab]();
  });
  // End Navigation

  // Social post dialog
  $('.navbar-search-lg textarea').keydown(function(e){
    if (e.keyCode == 13 && !e.shiftKey) {
      e.preventDefault();
      return false;
    }
  });

  $('.navbar-search .post-settings .schedule').on('click', function(){
    $(this).hide().next().show();
  });

  $('.navbar-search .post-settings .cancel-schedule').on('click', function(){
    $(this).parent().hide().prev().show();
  });

  $('.navbar-search .post-settings .social-networks .btn').on('click', function(){
    $(this).toggleClass('btn-primary');
  }).tooltip();

  $('.navbar-search-sm input').on('focus', function(){
    $(this).parent().parent().hide();
    $('.navbar-search-lg').show().find('textarea').focus();
    $('.progressjs-progress').show();
  });

  $('html').click(function() {
    $('.navbar-search-lg').hide();
    $('.navbar-search-sm').show().find('input').val(window.clipText($('.navbar-search-lg textarea').val(), 52));
    $('.progressjs-progress').hide();
  });

  $('.navbar-search-lg').click(function(event){
      event.stopPropagation();
  });

  $('.navbar-search-lg textarea').on('keyup', function() {
    var prgjs = progressJs($(this)).setOptions({ theme: 'blackRadiusInputs' }).start();
    var counter = $(this).parent().find(".post-counter");
    var limit = 140; // determined based on selected social networks

    counter.text(limit - this.value.length);

    if (this.value.length <= limit) {
      prgjs.set(Math.floor(this.value.length * 100/limit));
    } else {
      this.value = this.value.substring(0, limit);
    }
  });
  // End Social post dialog

  // inits['analytics'] = function(){
  //   _(['likes-over-time','views-over-time']).each(function(x){
  //       $('#'+x).highcharts({
  //           title: {
  //               text: 'All Releases',
  //               x: -20 //center
  //           },
  //           xAxis: {
  //               categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  //                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
  //           },
  //           yAxis: {
  //               title: {
  //                   text: 'Likes'
  //               },
  //               plotLines: [{
  //                   value: 0,
  //                   width: 1,
  //                   color: '#808080'
  //               }]
  //           },
  //           legend: {
  //               layout: 'vertical',
  //               align: 'right',
  //               verticalAlign: 'middle',
  //               borderWidth: 0
  //           },
  //           series: [{
  //               name: 'First Release',
  //               data: [17.0, 16.9, 19.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 19.6]
  //           }, {
  //               name: 'Second Release',
  //               data: [10, 18, 15.7, 11.3, 17.0, 22.0, 24.8, 24.1, 20.1, 14.1, 18.6, 12.5]
  //           }, {
  //               name: 'Third Release',
  //               data: [9, 0.6, 3.5, 8.4, 13.5, 17.0, 18.6, 17.9, 14.3, 9.0, 3.9, 1.0]
  //           }, {
  //               name: 'Fourth Release',
  //               data: [3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]
  //           }]
  //       });
  //   });

  //   $('#emails').highcharts({
  //       chart: {
  //           zoomType: 'xy'
  //       },
  //       title: {
  //           text: 'Email Marketing'
  //       },
  //       xAxis: [{
  //           categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  //               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
  //       }],
  //       yAxis: [{ // Primary yAxis
  //           labels: {
  //               format: '{value}',
  //               style: {
  //                   color: Highcharts.getOptions().colors[1]
  //               }
  //           },
  //           title: {
  //               text: 'Emails Sent',
  //               style: {
  //                   color: Highcharts.getOptions().colors[1]
  //               }
  //           }
  //       }, { // Secondary yAxis
  //           title: {
  //               text: 'Open Rate',
  //               style: {
  //                   color: Highcharts.getOptions().colors[0]
  //               }
  //           },
  //           labels: {
  //               format: '{value} %',
  //               style: {
  //                   color: Highcharts.getOptions().colors[0]
  //               }
  //           },
  //           opposite: true
  //       }],
  //       tooltip: {
  //           shared: true
  //       },
  //       legend: {
  //           layout: 'vertical',
  //           align: 'left',
  //           x: 120,
  //           verticalAlign: 'top',
  //           y: 100,
  //           floating: true,
  //           backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
  //       },
  //       series: [{
  //           name: 'Open Rate',
  //           type: 'column',
  //           yAxis: 1,
  //           data: [49.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1, 95.6, 54.4],
  //           tooltip: {
  //               valueSuffix: ' %'
  //           }

  //       }, {
  //           name: 'Emails Sent',
  //           type: 'spline',
  //           data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6],
  //       }]
  //   });

  //   var gaugeOptions = {

  //       chart: {
  //           type: 'solidgauge'
  //       },

  //       title: null,

  //       pane: {
  //           center: ['50%', '85%'],
  //           size: '140%',
  //           startAngle: -90,
  //           endAngle: 90,
  //           background: {
  //               backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || '#EEE',
  //               innerRadius: '60%',
  //               outerRadius: '100%',
  //               shape: 'arc'
  //           }
  //       },

  //       tooltip: {
  //           enabled: false
  //       },

  //       // the value axis
  //       yAxis: {
  //           stops: [
  //               [0.1, '#55BF3B'], // green
  //               [0.5, '#DDDF0D'], // yellow
  //               [0.9, '#DF5353'] // red
  //           ],
  //           lineWidth: 0,
  //           minorTickInterval: null,
  //           tickPixelInterval: 400,
  //           tickWidth: 0,
  //           title: {
  //               y: -70
  //           },
  //           labels: {
  //               y: 16
  //           }
  //       },

  //       plotOptions: {
  //           solidgauge: {
  //               dataLabels: {
  //                   y: 5,
  //                   borderWidth: 0,
  //                   useHTML: true
  //               }
  //           }
  //       }
  //   };

  //   $('#sentiment').highcharts(Highcharts.merge(gaugeOptions, {
  //       yAxis: {
  //           min: 0,
  //           max: 100,
  //           title: {
  //               text: 'Positive',
  //               y: 20
  //           }
  //       },

  //       credits: {
  //           enabled: false
  //       },

  //       series: [{
  //           name: 'Polarity',
  //           data: [50],
  //           dataLabels: {
  //               format: '<div style="text-align:center"><span style="font-size:25px;color:' +
  //                   ((Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black') + '">{y}</span><br/>' +
  //                      '<span style="font-size:12px;color:silver">%</span></div>'
  //           },
  //           tooltip: {
  //               valueSuffix: ' %'
  //           }
  //       }]

  //   }));
  // }

  // inits['releases'] = function(){
  //   _(_.range(3)).each(function(){
  //     $('.releases').append(_.template($('#_releases_release').text())({
  //       name: window.capitalize(chance.word({syllables: 3})),
  //       text: window.clipText(chance.sentence({words: 20}), 124),
  //       fans: chance.natural({min: 200, max: 4000}),
  //       engagements: chance.natural({min: 5, max: 5000}),
  //       releases: chance.natural({min: 2, max: 20})
  //     }));
  //   });

  //   if($('.edit-release').length == 0) {
  //     // to make sure these things run once
  //     $(_.template($('#_releases_edit').text())({})).appendTo('body');
  //     $(_.template($('#_releases_blast').text())({})).appendTo('body');
  //     $('#release-text').wysihtml5({toolbar:{"fa":true}});      
  //   }

  //   $('.edit-release #release-media .add-photo').on('click', function(){
  //     uploadcare.openDialog(null, {
  //       previewStep: true
  //     }).done(function(file) {
  //       file.promise().done(function(fileInfo){
  //         console.log(fileInfo.cdnUrl);
  //       });
  //     });
  //   });
  // }

  // inits['robin8'] = function() {
  //   _(['home','analysis','targets','pitch']).each(function(x){
  //     $('#blast-'+x).html(_.template($('#_releases_blast_'+x).text(),{})());
  //   });

  //   $('.blast-content select').on('change', function(){
  //     if($(this).val() == 0) {
  //       $('.blast-content #analyze').hide();
  //       $('.blast-content #new-release').show();
  //     } else {
  //       $('.blast-content #analyze').show();
  //       $('.blast-content #new-release').hide();
  //     }
  //   });

  //   $('.blast-steps li a').on('click', function() {
  //     $(this).parent().parent().find('li.colored').removeClass('colored');
  //     $(this).parent().prevAll().each(function(){ $(this).addClass('colored') });
  //   });

  //   $('.blast-content #release-category').editable();

  //       $('.blast-content #release-topics').editable({
  //           source: [
  //                 {id: 'ai', text: 'Artificial Intelligence'},
  //                 {id: 'dm', text: 'Data Mining'},
  //                 {id: 'ml', text: 'Machine Learning'},
  //                 {id: 'nlp', text: 'Natural Language Processing'},
  //                 {id: 'db', text: 'Dublin'},
  //                 {id: 'ln', text: 'London'},
  //                 {id: 'api', text: 'API'}
  //              ],
  //           select2: {
  //              multiple: true
  //           }
  //       });

  //       $('[data-toggle=tooltip]').tooltip();
  //       $('#summary-slider').slider({
  //         value:2,
  //     min: 0,
  //     max: 10,
  //     step: 1,
  //     slide: function( event, ui ) {
  //       $( "#summary-slider-amount" ).text( ui.value + ' sentences' );
  //     }
  //       });
  // }

  // inits['social'] = function(){
  //   $.fn.editable.defaults.mode = 'inline';
  //   $('.list-group-item .editable').editable();
  //   $('[data-toggle=tooltip]').tooltip();
  //   $('.social-networks .btn').on('click', function(){
  //     $(this).toggleClass('btn-primary');
  //   });
  // }

  // inits['newsrooms'] = function(){
  //   _(_.range(5)).each(function(){
  //     $('.newsrooms').append(_.template($('#_newsrooms_newsroom').text())({
  //       name: window.capitalize(chance.word({syllables: 3})),
  //       text: window.clipText(chance.sentence({words: 20}), 124),
  //       fans: chance.natural({min: 200, max: 4000}),
  //       engagements: chance.natural({min: 5, max: 5000}),
  //       releases: chance.natural({min: 2, max: 20})
  //     }));
  //   });

  //   $('.edit-newsroom #media .add-photo').on('click', function(){
  //     uploadcare.openDialog(null, {
  //       previewStep: true
  //     }).done(function(file) {
  //       file.promise().done(function(fileInfo){
  //         console.log(fileInfo.cdnUrl);
  //       });
  //     });
  //   });
  // }

  // inits['monitoring'] = function(){
  //   $("#add-stream").tooltip({title: 'Add Stream', trigger: 'hover', placement: 'left'});
  //   $("#add-stream").on('click', function(){
  //     $('.stream-container').append(getStream());
  //     $('.stream-body').height($(window).height() - 90 - 12);
  //   });

  //   function getStream(){
  //     var html = _.template($("#_monitoring_stream").text())(
  //       {
  //         title: chance.pick(['Apple Inc.', 'Microsoft', 'MyPRGenie', 'AYLIEN', 'Technology', 'Hardware', 'Labor']),
  //         updates: chance.natural({min: 1, max: 10})
  //       }
  //     );
  //     var html = $(html);
  //     html.find('.sort-by select').on('change', function(){
  //       var val = $(this).val();
  //       if(val == "2") {
  //         html.find('.stream-settings .time-range').show();
  //         html.find('.stream-settings').addClass('expand');
  //       } else if(val == "1") {
  //         html.find('.stream-settings .time-range').hide();
  //         html.find('.stream-settings').removeClass('expand');
  //       }
  //     });
  //     _(_.range( chance.natural({min: 8, max: 15}) )).each(function(i){
  //       html.find(".stories").append(_.template($("#_monitoring_story").text())(
  //         {
  //           name: chance.name(),
  //           text: chance.sentence({words: 9}),
  //           timeago: chance.natural({min: 1, max: 24}),
  //           likes: chance.natural({min: 5, max: 347})
  //         }
  //       ));
  //     });
  //     return html;
  //   }

  //   _(_.range(chance.natural({min: 2, max: 4}))).each(function(i){
  //     $(".stream-container").append(getStream());
  //   });

  //   $(".stream-container").sortable({
  //     handle: '.stream-header'
  //   });
  //   $(".stream-container").disableSelection();

  //   $('.delete-stream').on('click', function(){
  //     swal({
  //       title: "Delete Stream?",
  //       text: "You will not be able to recover this stream.",
  //       type: "error",
  //       showCancelButton: true,
  //       confirmButtonClass: 'btn-danger',
  //       confirmButtonText: 'Delete'
  //     });
  //   });

  //   $('.settings-button').on('click', function(){
  //     $(this).parent().parent().find('.slider').toggleClass('closed');
  //   });

  //   $('.likes').tooltip({title: '<i class="fa fa-facebook-square"></i> 35 <i class="fa fa-twitter-square"></i> 17 <i class="fa fa-google-plus-square"></i> 5', trigger: 'hover', placement: 'right', html: true});
  //   $('[data-toggle=tooltip]').tooltip({trigger:'hover'});
  //   $('.stream-body').height($(window).height() - 90 - 12);
  // }
});