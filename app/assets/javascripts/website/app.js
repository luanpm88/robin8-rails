$(document).foundation();

function setsizes(){

    $('.sizeheader').css('height',$(window).height());


    var signuplogomargin = $(window).height()/2 - 80;
    $('.sizeheader h1.logo').css('margin-top',signuplogomargin + 'px');

    var logomargin = $(window).height()/2 - 140;
    $('.homeheader h1.logo').css('margin-top',logomargin + 'px');


    var bgposition = $(window).width()/2;

    $('.screenpane').css('background-position', bgposition + 'px bottom');

}


$(document).ready(function(){



    /* SET SIZES FOR LEADERBOARDS */
    setsizes();


    /* HOMEPAGE SCROLL BUTTON */
    $( ".learn-more" ).click(function() {
        $('html, body').animate({
            scrollTop: $(window).height()
        }, 600);
    });

    /* STEP 2 functions */

    /*
     $('.errorwarning').hide();


     $( "#planselect-button" ).click(function(e) {
     if($('input#plan-selection').val() == '' || !$('input#plan-selection').val()) {
     e.preventDefault();
     $('.errorwarning').fadeIn();
     }
     });*/

    //$('.business-plans').show();
    //
    //$('.agency-plans').hide();
    //
    //
    //$( "#selected-businesses" ).click(function() {
    //    if(!$(this).is('active')){
    //        $('.agency-plans').fadeOut();
    //        setTimeout(function(){ $('.business-plans').fadeIn();}, 500);
    //        $('.tab-nav a').removeClass('active');
    //        $(this).addClass('active');
    //    }
    //});
    //$( "#selected-agencies" ).click(function() {
    //    if(!$(this).is('active')){
    //        $('.business-plans').fadeOut();
    //        setTimeout(function(){ $('.agency-plans').fadeIn();}, 500);
    //        $('.tab-nav a').removeClass('active');
    //        $(this).addClass('active');
    //    }
    //});


    //$( ".subscription-type" ).click(function() {
    //
    //    var disableclass='n';
    //    if($(this).hasClass('active')){
    //        disableclass='y';
    //    }
    //    $('input#plan-selection').val($(this).data('plan'));
    //    $('.subscription-type').removeClass('active');
    //    $('.button-planselector').text('Select');
    //
    //    if(disableclass == 'y'){
    //        $('.active .button-planselector').text('Select');
    //        $('input#plan-selection').val('');
    //    }else{
    //        $(this).addClass('active');
    //        $('.active .button-planselector').text('Selected');
    //    }
    //
    //
    //});


    /* QUANTITY FUNCTIONS FOR STEP 3 */

    $( ".qty-plus" ).click(function() {
        var target="#"+$(this).data('qty');
        var oldvalue = $(target).val();
        var newvalue = parseFloat($(target).val()) + 1;
        $(target).val(newvalue);
    });
    $( ".qty-minus" ).click(function() {
        var target="#"+$(this).data('qty');
        var oldvalue = $(target).val();
        if (oldvalue > 0) {
            var newVal = parseFloat(oldvalue) - 1;
        } else {
            newVal = 0;
        }
        $(target).val(newVal);
    });


    /* CHECKOUT REMOVE */

    $( ".remove" ).click(function() {
        var removeid = "#"+ $(this).data('remove');
        $(removeid).remove();
    });



    $('#checkoutform')
        .on('invalid.fndtn.abide', function () {
            $('html, body').animate({
                scrollTop: $('#checkoutdata').offset().top + 100
            }, 600);
        })
        .on('valid.fndtn.abide', function () {
        });



});

$( window ).resize(function() {
    setsizes();

});
/* NAVIGATION SCROLL sticky */
$(window).on('scroll', function() {
    scrollPosition = $(this).scrollTop();
    if (scrollPosition >= 1) {
        $('.nav').addClass('fixedscroll');
    }else{
        $('.nav').removeClass('fixedscroll');
    }
});
