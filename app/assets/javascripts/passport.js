//= require assets
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require cable

var AlertBox = function(container, renderFunc) {
    var container = $(container || 'body');

    var render = renderFunc || function(msg, type) {
        var element = $('<div class="alert alert-'+ (type || "info") +'">' + msg + '</div>');
        container.append(element.hide());
        return element;
    }

    return {
        show: function(msg, type) {
            var element = render(msg, type);
            element.slideDown();
        },
        once: function(msg, type) {
            var element = render(msg, type);
            element.slideDown().delay(3000).slideUp(function() {
                element.remove();
            });
        },
        clear: function() {
            container.children().each(function(index, el) {
                var element = $(el);
                element.slideUp(function() {
                    element.remove();
                });
            });
        }
    }
};

$(function(){
    var top = ($(window).height() - $(".form-wrap").height()) / 2;
    $(".form-wrap").css("margin-top", top > 0 ? top : 0).fadeIn();

    setTimeout(function() {
        $(".form-wrap input.form-control").val("");
    }, 500);

    $(".form-wrap input").focus(function(event) {
        formAlert.clear();
    });

    var formTopAlert = AlertBox(".form-top-alert"),
        formAlert = AlertBox('.form-alert-wrap');

    $(".alert-data").each(function(index, el) {
        formTopAlert.once($(el).data("message"), $(el).data("type"));
        $(el).remove();
    });

    $('[data-toggle="tooltip"]').tooltip();

    var captchaImage = $(".captcha-image");
    captchaImage.click(function(){
        if (captchaImage.hasClass('disabled')) return;

        $.ajax({
            method: "GET",
            url: "/rucaptcha/"
        }).done(function(data){
            src = captchaImage.attr('src').split('?')[0] + '?' + (new Date()).getTime();
            captchaImage.attr("src", src);
            captchaImage.removeClass('disabled');
        });
        captchaImage.addClass('disabled');
    });

    var smsCodeBtn = $('.sms-code-btn'),
        remainingNumber = smsCodeBtn.data("remaining");

    var smsTimeCounter = (function(element) {
        var counter, countNumber;

        return {
            run: function(number) {
                if (!!counter) return;

                countNumber = number || 60;
                element.data("txt", element.html());
                element.attr('disabled', true);
                counter = setInterval(function() {
                    element.html(countNumber + " (秒)");
                    countNumber -= 1;
                    if (countNumber < 0) {
                        clearInterval(counter);
                        counter = null;
                        element.html(element.data("txt"));
                        element.attr('disabled', false);
                    }
                }, 1000);
            }
        }
    })(smsCodeBtn);

    if (remainingNumber) {
        smsTimeCounter.run(remainingNumber);
    }

    smsCodeBtn.click(function(){
        var captchaCode, mobileNumber = $('.mobile-number').val().trim();

        if (!!smsCodeBtn.attr('disabled'))
            return false;

        if (!(mobileNumber && mobileNumber.length > 0))
            return formAlert.once("没有正确填写手机号", "danger");

        if (captchaImage.size() > 0) {
            captchaCode = $('.captcha-code').val().trim();
            if(!(captchaCode && captchaCode.length > 0))
                return formAlert.once("没有填写图片验证码", "danger");
        }

        smsCodeBtn.attr('disabled', true);
        $.ajax({
            method: 'POST',
            url: '/passport/sender/sms',
            data: {
                'phone': mobileNumber,
                '_rucaptcha': captchaCode,
                'forget_password': smsCodeBtn.data("forget-password")
            },
            beforeSend: function(xhr){
                var token = $('meta[name="csrf-token"]').attr('content');
                xhr.setRequestHeader('X-CSRF-Token', token);
            }
        }).done(function(data){
            formAlert.once(data.msg, "success");
            if (!!data.skip) {
                smsCodeBtn.attr('disabled', false);
                return;
            }
            smsTimeCounter.run();
        }).fail(function(xhr, status) {
            var data = xhr.responseJSON || JSON.parse(xhr.responseText);
            formAlert.once(data.error, "danger");
            smsCodeBtn.attr('disabled', false);
            captchaImage.click();
        });
    });

    $('.form-wrap form').on('ajax:success', function(e, data, status, xhr){
        formAlert.show(data.msg, "success");
        setTimeout(function() {
            window.location.href = data.ok_url || "/";
        }, 500);
    }).on('ajax:error',function(e, xhr, status, error){
        var data = xhr.responseJSON || JSON.parse(xhr.responseText);
        if (!data) data = { error: "请求发生异常，请重试" };
        formAlert.show(data.error, "danger");
    }).on('ajax:beforeSend',function(xhr, settings){
        var submitBtn = $(this).find("[type='submit']");
        if (submitBtn.hasClass('disabled')) return false;
        submitBtn.data("txt", submitBtn.html());
        submitBtn.html(submitBtn.data("loading-txt")).addClass('disabled');
    }).on('ajax:complete',function(xhr, status){
        var submitBtn = $(this).find("[type='submit']");
        submitBtn.html(submitBtn.data("txt")).removeClass('disabled');
    });
});
