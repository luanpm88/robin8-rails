function productLikeAnimate(id,type){
    var product = $('.product'+id);
    var likeArea = product.find('.like-area');
    if(type == 0){
        likeArea.removeClass('liked');
        if(product.hasClass('product-v3')){
            likeArea.find('span').html(product.attr('data-like-count'));
        }
    }else{
        likeArea.addClass('liked');
        if(product.hasClass('product-v3')){
            likeArea.find('span').html('已喜欢');
        }
    }
}

Zepto(function($){
    var newBanner = $('.ani-banner');
    var wrapper = $('.wrapper');

    var w = wrapper.width();
    var h = Math.floor(w*0.55);

    if(newBanner && newBanner.length > 0){
        newBanner.css({
            'height':h+'px',
            'width':w+'px',
            'left':'50%',
            'margin-left':(-w/2)+'px',
            'max-width':'640px'
        });
        wrapper.css('padding-top',h+'px');
    }
    wrapper.find('.title').css('padding-top','16px');

    var lazyImg = $('.lazy');

    lazyImg.each(function(){
        var _this = $(this);
        var url = _this.attr('data-original');

        $('<img />').one('load',function(){
            if(_this.is('img')){
                _this.attr('src',url);
            }else{
                _this.css('background-image','url('+url+')');
            }
            setTimeout(function(){
                _this.css('opacity','1');
            },15);
        }).attr('src',url);
    });

    var productV2s = $('.product-v2');
    productV2s.each(function(){
        var _this = $(this);
        var id = _this.attr('data-id');
        _this.addClass('product'+id);
        var score = parseInt(_this.find('.score').html());
        if(score == 10){
            _this.find('.score').html('10')
        }
        var stars = _this.find('.stars ul li i');
        var m = Math.floor(score/2),
            n = score%2;
        for(var i=0;i<m;i++){
            $(stars[i]).removeClass('star-0').addClass('star-2');
        }
        if(n > 0){
            $(stars[m]).removeClass('star-0').addClass('star-1');
        }
    });

    var productV2LikeAreas = $('.product-v2 .like-area');
    productV2LikeAreas.on('click',function(e){
        e.preventDefault();
        var _this = $(this);
        var id = _this.parent().parent().attr('data-id');
        var picUrl = _this.parent().parent().find('.cover').css('background-image');
        picUrl = picUrl.substring(4,picUrl.length-1);
        picUrl = encodeURIComponent(picUrl);
        if(_this.hasClass('liked')){
            window.location.href = 'bantang://com.jzyd.BanTang/brand_product/like/click?id='+id+'&like_state=1&pic='+picUrl;
        }else{
            window.location.href = 'bantang://com.jzyd.BanTang/brand_product/like/click?id='+id+'&like_state=0&pic='+picUrl;
        }
    });

    var productV3s = $('.product-v3');
    productV3s.each(function(){
        var _this = $(this);
        var id = _this.attr('data-id');
        _this.addClass('product'+id);
        //var score = parseInt(_this.find('.score').html());
        //if(score == 10){
        //    _this.find('.score').html('10')
        //}
        //var stars = _this.find('.stars ul li i');
        //var m = Math.floor(score/2),
        //    n = score%2;
        //for(var i=0;i<m;i++){
        //    $(stars[i]).removeClass('star-0').addClass('star-2');
        //}
        //if(n > 0){
        //    $(stars[m]).removeClass('star-0').addClass('star-1');
        //}
    });

    var productV3LikeAreas = $('.product-v3 .like-area');
    productV3LikeAreas.on('click',function(e){
        e.preventDefault();
        var _this = $(this);
        var id = _this.parent().parent().attr('data-id');
        var picUrl = _this.parent().parent().find('.cover').css('background-image');
        picUrl = picUrl.substring(4,picUrl.length-1);
        picUrl = encodeURIComponent(picUrl);
        if(_this.hasClass('liked')){
            window.location.href = 'bantang://com.jzyd.BanTang/brand_product/like/click?id='+id+'&like_state=1&pic='+picUrl;
        }else{
            window.location.href = 'bantang://com.jzyd.BanTang/brand_product/like/click?id='+id+'&like_state=0&pic='+picUrl;
        }
    });

    if(!window.navigator.userAgent.match(/bantang/i)){
        var products = $('.product a');
        if(!window.navigator.userAgent.match(/micromessenger/i)){
            products.each(function(){
                var _this = $(this);
                _this.attr('target','_blank');
                var href = _this.attr('href');
                if(href.indexOf('brand_product') >= 0){
                    var pId = Util.getQueryString(href)['id'];
                    _this.attr('href','http://m.ibantang.com/product/brandDetail/'+pId);
                }else{
                    var oUrl = Util.getQueryString(href)['product_url'];
                    _this.attr('href',decodeURIComponent(oUrl));
                }
            });
        }
        products.on('click',function(){
            if($(this).attr('href').match(/bantang:/i)){
                Util.DownloadShow();
            }
        });

        var productV2Links = $('.product-v2 a');
        if(!window.navigator.userAgent.match(/micromessenger/i)){
            productV2Links.each(function(){
                var _this = $(this);
                _this.attr('target','_blank');
                var href = _this.attr('href');
                if(href.indexOf('brand_product') >= 0){
                    var pId = Util.getQueryString(href)['id'];
                    _this.attr('href','http://m.ibantang.com/product/brandDetail/'+pId);
                }else{
                    var oUrl = Util.getQueryString(href)['product_url'];
                    _this.attr('href',decodeURIComponent(oUrl));
                }
            });
        }
        productV2Links.on('click', function () {
            if($(this).attr('href').match(/bantang:/i)) {
                Util.DownloadShow();
            }
        });

        var productV3Links = $('.product-v3 a');
        if(!window.navigator.userAgent.match(/micromessenger/i)){
            productV3Links.each(function(){
                var _this = $(this);
                _this.attr('target','_blank');
                var href = _this.attr('href');
                if(href.indexOf('brand_product') >= 0){
                    var pId = Util.getQueryString(href)['id'];
                    _this.attr('href','http://m.ibantang.com/product/brandDetail/'+pId);
                }else{
                    var oUrl = Util.getQueryString(href)['product_url'];
                    _this.attr('href',decodeURIComponent(oUrl));
                }
            });
        }
        productV3Links.on('click', function () {
            if($(this).attr('href').match(/bantang:/i)) {
                Util.DownloadShow();
            }
        });
    }

    //animate banner
    if(newBanner.length > 0 && !window.navigator.userAgent.match(/bantang/i)) {
        var sY=0,mY=0,eY=0;
        wrapper.on('touchstart', function (e) {
            var touch = e.touches[0];
            sY = touch.pageY;
        }).on('touchmove', function (e) {
            var pageScrollTop = $('body').scrollTop();
            if (pageScrollTop <= 0) {
                var touch = e.touches[0];
                mY = touch.pageY;
                var disY = mY - sY;
                if (disY > 0) {
                    e.preventDefault();
                    wrapper.css('transform', 'translate(0px,' + disY / 3 + 'px)');
                    newBanner.css('transform', 'scale(' + (1 + disY / (1.2 * h)) + ')');
                }
            }
        }).on('touchend', function (e) {
            var pageScrollTop = $('body').scrollTop();
            if (pageScrollTop <= 0) {
                var touch = e.changedTouches[0];
                eY = touch.pageY;
                wrapper.animate({
                    translate3d: '0px,0px,0px'
                }, 300, 'linear',function(){
                    wrapper.css('transform',null);
                });
                newBanner.animate({
                    scale: 1
                }, 300, 'linear');
            }
        });
    }
});