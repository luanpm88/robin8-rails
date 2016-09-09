/**
 * Created by PH on 15/8/8.
 */
var wxUtil = wxUtil || {};

wxUtil.host = 'http://m.ibantang.com:3010';
wxUtil.noncestr = 'kafbk*&#akh=^';
wxUtil.appId = 'wx2ba1275057d702f8';

wxUtil.title = document.getElementById('wxShareTitle') ?
    document.getElementById('wxShareTitle').value : '';
wxUtil.desc = document.getElementById('wxShareDesc') ?
    document.getElementById('wxShareDesc').value : '';
wxUtil.imgUrl = document.getElementById('wxSharePic') ?
    document.getElementById('wxSharePic').value : 'http://7q5fp7.com2.z0.glb.qiniucdn.com/wxshare/logo.jpg';

wxUtil.getSign = function(){
    this.timestamp = Math.floor(new Date().getTime()/1000);
    var xhr = new XMLHttpRequest();
    var url = wxUtil.host+'/getSign/getSignature';
    xhr.open('POST',url,true);
    xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
    xhr.onreadystatechange = function(){
        if(xhr.readyState==4) {
            if(xhr.status==200) {
                var data = eval('(' + xhr.responseText + ')');
                wx.config({
                    debug: false,
                    appId: wxUtil.appId,
                    timestamp: wxUtil.timestamp,
                    nonceStr: wxUtil.noncestr,
                    signature: data.sig,
                    jsApiList: ['onMenuShareTimeline','onMenuShareAppMessage']
                });
            }
        }
    }
    xhr.send('timestamp='+escape(this.timestamp.toString())+'&currentUrl='
        +escape(document.location.href)+'&noncestr='+escape(this.noncestr));
}

wxUtil.shareTimeLine = function(callback){
    wx.onMenuShareTimeline({
        title: wxUtil.title,
        imgUrl: wxUtil.imgUrl,
        success: function(){
            callback();
        },
        cancel: function(){}
    });
}

wxUtil.shareAppMessage = function(callback){
    wx.onMenuShareAppMessage({
        title: wxUtil.title,
        desc: wxUtil.desc,
        imgUrl: wxUtil.imgUrl,
        success: function(){
            callback();
        },
        cancel: function(){}
    });
}

wxUtil.incShareTimelineCounts = function(){
    var xhr = new XMLHttpRequest();
    var url = wxUtil.host+'/shareCount/incShareTimelineCounts';
    xhr.open('POST',url,true);
    xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
    xhr.send('pageUrl='+escape(document.location.href));
}

wxUtil.incShareAppMessageCounts = function(){
    var xhr = new XMLHttpRequest();
    var url = wxUtil.host+'/shareCount/incShareAppMessageCounts';
    xhr.open('POST',url,true);
    xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
    xhr.send('pageUrl='+escape(document.location.href));
}


wxUtil.getSign();

wx.ready(function(){
    wxUtil.shareTimeLine(wxUtil.incShareTimelineCounts);
    wxUtil.shareAppMessage(wxUtil.incShareAppMessageCounts);
});

