;(function($){
    $.extend($.fn, {
        cookie : function (key, value, options) {
            var days, time, result, decode

            // A key and value were given. Set cookie.
            if (arguments.length > 1 && String(value) !== "[object Object]") {
                // Enforce object
                options = $.extend({}, options)

                if (value === null || value === undefined) options.expires = -1

                if (typeof options.expires === 'number') {
                    days = (options.expires * 24 * 60 * 60 * 1000)
                    time = options.expires = new Date()

                    time.setTime(time.getTime() + days)
                }

                value = String(value)

                return (document.cookie = [
                    encodeURIComponent(key), '=',
                    options.raw ? value : encodeURIComponent(value),
                    options.expires ? '; expires=' + options.expires.toUTCString() : '',
                    options.path ? '; path=' + options.path : '',
                    options.domain ? '; domain=' + options.domain : '',
                    options.secure ? '; secure' : ''
                ].join(''))
            }

            // Key and possibly options given, get cookie
            options = value || {}

            decode = options.raw ? function (s) { return s } : decodeURIComponent

            return (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie)) ? decode(result[1]) : null
        }

    })
})(Zepto);

var Util = Util || {};

Util.DownloadShow = function(inparams) {
    var params = {
        maskerID: 'modelOverlay',
        contentID: 'modelContent',
        alpha: 0.35,
        bgColor: '#000',
        dbclick: true,
        keydown: true,
        mZindex: 9997,
        cZindex: 9999
    };

    if (inparams && typeof(inparams) == 'object') {
        for (var key in inparams) {
            if (key.match(/^_/)) {
                continue
            }
            params[key] = inparams[key]
        }
    };
    var de = document.documentElement;
    var _width = de.clientWidth;
    var _height = de.clientHeight;
    $(window).size(function() {
        _width = de.clientWidth;
        _height = de.clientHeight;
    });
    var top = Math.floor(_height/2-60);
    var html = '<div id="'+ params.maskerID +'" style="position:fixed;left:0;top:0;right:0;bottom:0;z-index:' + params.mZindex + ';background-color:rgba(0,0,0,.4);"></div>';
    html += '<div id="' + params.contentID + '" class="model-dialog" style="z-index:' + params.cZindex + ';position:fixed;left:50%;width:224px;padding:0 10px;margin-left:-122px;top:'+top+'px;background-color:#fff;border-radius:4px;">';
    html += '<p style="height: 80px;line-height: 80px;font-size: 14px;color:#444;text-align: center;">想使用更多功能？请下载半糖</p>';
    html += '<div style="border-top:1px solid #d8d8d8;height: 20px;padding: 10px 0;line-height: 20px;font-size: 13px;">' +
    '<a class="icon-close" style="display:block;float:left;width: 111px;height:20px;border-right:1px solid #d8d8d8;color:#999;text-align: center;" href="javascript:;">取消</a>' +
    '<a style="display:block;float:left;width: 112px;height:20px;color:#ec5252;text-align: center;" href="http://m.bantangapp.com/appview/downapp.html?current_page='+window.location.href+'">去下载</a>' +
    '<div>';
    html += '</div>';
    $('body').css("overflow","hidden");
    $(html).appendTo('body').fadeIn(200);

    var modelBox = $('#' + params.maskerID);
    var modelBody = $('#' + params.contentID);
    var iconClose = $('.icon-close');
    if(iconClose){
        iconClose.click(function(){
            Util.modelClose(modelBox, modelBody);
        });
    }
    if (params.dbclick) {
        modelBox.click(function(e) {
            e = e || window.event;
            var ele = e.srcElement ? e.srcElement : e.target;
            Util.modelClose(modelBox, modelBody);
        })
    }
    if (params.keydown) {
        document.onkeydown = function(event) {
            event = window.event || event;
            var keyCode = event.keyCode || event.which || event.charCode;
            if (event.keyCode == 27) {
                Util.modelClose(modelBox, modelBody);
            }
        }
    }
}

Util.modelClose = function(o, m) {
    o.fadeOut(function() {
        o.remove();
    });
    m.fadeOut(function() {
        m.remove();
        $('body').css("overflow","auto");
    })
};

Util.getQueryString = function(url){
    var queryString = url.split('?')[1];
    if(!queryString) return;
    queryString = queryString.split('&');
    var queries = {};
    for(var i= 0,len=queryString.length;i<len;i++){
        var tmp = queryString[i].split('=');
        queries[''+tmp[0]] = tmp[1];
    }
    return queries;
}

Util.loadTopicComment = function(){
    var createTopicCommentHTML = function(data){
        if(data.length <= 0){
            return;
        }
        var htmlStr = '<div class="comment-list" style="position: relative;padding-top: 10px;background-color: #f4f4f4;z-index: 3;">';
        htmlStr += '<div class="inner" style="background-color: #fff;padding: 0 20px;margin:0;">';
        for(var i= 0,len=data.length;i<len;i++){
            htmlStr += '<div class="comment-item" style="padding: 20px 0;border-bottom: 1px solid #f4f4f4;background-color: #fff;">' +
            '<div class="avatar" style="float:left;;width:30px;height:30px;border-radius:15px;background: #f4f4f4 url('+data[i].user.avatar+') center no-repeat;background-size:cover;"></div>' +
            '<div class="info" style="padding:0 0 0 40px;height: auto;">' +
            '<p class="nickname-time" style="height: 13px;line-height: 13px;padding-top: 4px;">' +
            '<span class="nickanme" style="float: left;color: #5D9CBC;font-size: 13px;">'+data[i].user.nickname+'</span>' +
            '<span class="time" style="float: right;font-size: 12px;color: #bfbfbf;">'+data[i].datestr+'</span></p>' +
            '<p class="content" style="padding: 13px 0 0 0;color: #919191;font-size: 13px;line-height: 1.6;">'+(data[i].at_user.nickname?'回复<span style="color:#5D9CBC;">@'+data[i].at_user.nickname+'</span>：':'')+data[i].conent+'</p>' +
            '</div>' +
            '</div>';
        }
        htmlStr += '<p class="more" style="padding: 20px 0;font-size: 14px;text-align: center;color:#919191;">查看更多评论('+$('#totalComment').val()+'条)</p>';
        htmlStr += '</div>';
        htmlStr += '</div>';
        $('.wrapper').append(htmlStr);
        $('.more').on('click',function(){
            Util.DownloadShow();
        });
    }
    var queries = Util.getQueryString(window.location.href);
    if(queries && queries['id']){
        var topicId = queries['id'];

        $.ajax({
            url:'/appview/topicCommentList',
            type:'GET',
            dataType:'json',
            data:{
                'id':topicId,
                'currentPage':1,
                'pageSize':20
            },
            success:function(data){
                if(data.code == 1){
                    createTopicCommentHTML(data.data);
                }
            }
        });
    }
}

Util.lazyLoad = function(cn){
    var lazyImg = $('.'+cn);

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
        }).one('error',function(){
            _this.css('opacity','1');
        }).attr('src',url);
    });
}

Util.bantangVersion = function(){
    var ua = window.navigator.userAgent+' ';
    var version = ua.match(/bantang\/.+? /);
    if(!version){
        return;
    }
    version = version[0];
    version = version.substring(8,13);
    version = version.replace(/\./g,'');
    return version;
}

Util.isMobile = {
    Android: function() {
        return navigator.userAgent.match(/Android/i) ? true : false;
    },
    BlackBerry: function() {
        return navigator.userAgent.match(/BlackBerry/i) ? true : false;
    },
    iOS: function() {
        return navigator.userAgent.match(/iPhone|iPad|iPod/i) ? true : false;
    },
    Windows: function() {
        return navigator.userAgent.match(/IEMobile/i) ? true : false;
    },
    Weixin: function(){
        return navigator.userAgent.match(/MicroMessenger/i) ? true : false;
    },
    Bantang: function(){
        return navigator.userAgent.match(/bantang/i) ? true : false;
    },
    any: function() {
        return (Util.isMobile.Android() || Util.isMobile.BlackBerry()
        || Util.isMobile.iOS() || Util.isMobile.Windows() || Util.isMobile.Weixin());
    }
};

Util.dockBar = function(){
    var currUrl = window.location.href;
    if(!Util.isMobile.Bantang()
        && currUrl.indexOf('/cm/') < 0){
        //var btnTxt = '下载',
        //    url = 'http://m.bantangapp.com/appview/downapp.html';
        //if(Util.isMobile.Weixin()){
        //    btnTxt = '关注';
        //    url = 'http://mp.weixin.qq.com/s?__biz=MzAwNjE4ODI1Mw==&mid=208908385&idx=1&sn=d8d2fd6d27cd53f4987e633d87aa44ad&scene=0&from=singlemessage&isappinstalled=0#rd';
        //}
        //var dock = '<div class="bottom-bar" style="z-index: 99;">' +
        //    '<div class="logo"></div>' +
        //    '<div class="desc">' +
        //    '<h4>发现值得买的好东西</h4>' +
        //    '<p>年轻人的消费分享社区</p>' +
        //    '</div>' +
        //    '<a href="'+url+'" class="btn">'+btnTxt+'</a>' +
        //    '</div>';

        var openAppUrl = 'http://m.bantangapp.com/appview/downapp.html';
        var downloadUrl = 'http://m.bantangapp.com/appview/downapp.html';

        if(!Util.isMobile.Weixin()){
            if(currUrl.indexOf('/product/detail/') > 0){
                openAppUrl = 'bantang://com.jzyd.BanTang/product/detail?id=' + $('#productId').val();
            }
            if(currUrl.indexOf('/topic/detail/') > 0){
                openAppUrl = 'bantang://com.jzyd.BanTang/topic/detail?id=' + $('#topicId').val();
                if('undefined' != $('#topicType').val()){
                    openAppUrl += '&topic_type=' + $('#topicType').val();
                }
            }
            if(currUrl.indexOf('/appview/articlev2') > 0){
                openAppUrl = 'bantang://com.jzyd.BanTang/topic/detail?id=' + $('#topicId').val() + '&topic_type=2';
            }
            if(currUrl.indexOf('/post/detail/') > 0){
                openAppUrl = 'bantang://com.jzyd.BanTang/post/detail?id=' + $('#postId').val();
            }
        }

        var dock = '<div class="top-bar" style="z-index:99;">' +
            '<div class="inner">' +
            '<div class="logo"></div>' +
            '<div class="desc">' +
            '<h4>发现值得买的好东西</h4>' +
            '<p>www.ibantang.com</p>' +
            '</div>' +
            '<div class="clear"></div>' +
            '<div class="btn-area">' +
            '<a href="'+openAppUrl+'" class="open-app">在App内打开</a>' +
            '<a href="'+downloadUrl+'" class="download-app">下载App</a>' +
            '</div>' +
            '</div>' +
            '</div>';

        $('.wrapper').append(dock).css('padding-top','110px');
    }
}

Zepto(function($){
    var url = window.location.href;
    if(!window.navigator.userAgent.match(/bantang/i)
        && (url.indexOf('appview/article') >= 0 || url.indexOf('appview/zixun') >= 0)){
        Util.loadTopicComment();
    }

    Util.dockBar();
});