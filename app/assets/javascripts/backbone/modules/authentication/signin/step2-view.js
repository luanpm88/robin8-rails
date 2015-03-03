Robin.module('Authentication.SignIn', function(SignIn, App, Backbone, Marionette, $, _){

  SignIn.Step2View = Backbone.Marionette.ItemView.extend({
    template: 'modules/authentication/signin/templates/step2',

    onRender: function() {
      this.$el.find('.business-plans').show();
      this.$el.find('.agency-plans').hide();
      $('html, body').animate({
        scrollTop: 0
      }, 600);
    },

    events: {
      'click #selected-businesses' : 'selectBusinesses',
      'click #selected-agencies' : 'selectAgencies',
      'click .subscription-type' : 'selectSubscription'
    },

    selectBusinesses: function(e) {
      if(!$(e.target).is('active')){
        $('.agency-plans').fadeOut();
        setTimeout(function(){ $('.business-plans').fadeIn();}, 500);
        $('.tab-nav a').removeClass('active');
        $(e.target).addClass('active'); 
      }
    },

    selectAgencies: function(e) {
      if(!$(e.target).is('active')){
        $('.business-plans').fadeOut(); 
        setTimeout(function(){ $('.agency-plans').fadeIn();}, 500);
        $('.tab-nav a').removeClass('active');
        $(e.target).addClass('active'); 
      }
    },

    selectSubscription: function(e) {
      // console.log(this);
      // console.log($(e.target).parents('.subscription-type'));
      //need fix
      var disableclass='n';         
      if($(e.target).hasClass('active')){
        disableclass='y';
      } 
      $('input#plan-selection').val($(e.target).data('plan'));
      $('.subscription-type').removeClass('active');
      $('.button-planselector').text('Select');

      if(disableclass == 'y'){ 
        $('.active .button-planselector').text('Select');
        $('input#plan-selection').val('');
      }else{
        $(e.target).addClass('active');
        $('.active .button-planselector').text('Selected');
      }
    },

  });
});