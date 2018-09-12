var verify_phone = /^(0|86|17951)?(13[0-9]|15[012356789]|17[0-9]|18[0-9]|14[57])[0-9]{8}$/;  // 手机号码验证
var verify_email = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; // email校验
var verify_pw = /^.*(?=.{6,20})(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*?\(\)]).*$/; //密码校验，密码需要包含符号，英文大小写字母，6-20位字符

$(document).ready(function() {
  // 标签切换
  $('.tab-control').each(function() {
    var $tab_control = $(this);
    $tab_control.find('.tab-ctrl-tag').on('click', '.item', function(){
      var $that = $(this),
          index = $that.index(),
          $tags = $tab_control.find('.tab-ctrl-tag'),
          $content = $tab_control.find('.tab-content');
      $that.siblings('.item').removeClass('active');
      $that.addClass('active');
      $content.eq(index).siblings('.tab-content').removeClass('active');
      $content.eq(index).addClass('active');
    });
  });

  // 折叠标签
  $('.collapse-panel').each(function() {
    var $that = $(this),
        $collapse_tab = $that.find('.collapse-panel-tab'),
        $collapse_list = $that.find('.collapse-panel-content');
    $that.on('click', '.collapse-panel-tab', function() {
      if ($collapse_tab.hasClass('open')) {
        $collapse_list.removeClass('open');
        $collapse_tab.removeClass('open');
      } else {
        $collapse_tab.addClass('open');
        $collapse_list.addClass('open');
      }
    });
  });

  // 返回顶部
  $('#back_top_btn').hide();
  $(window).scroll(function () {
    if ($(window).scrollTop() >= 100) {
      $('#back_top_btn').show();
    } else {
      $('#back_top_btn').hide();
    }
  });
  $('#back_top_btn').click(function () {
    $('html, body').animate({ scrollTop: 0 }, 500);
  });
});

// 时间格式化
Date.prototype.customFormat = function(formatString) {
  var YYYY, YY, MMMM, MMM, MM, M, DDDD, DDD, DD, D, hhhh, hhh, hh, h, mm, m, ss, s, ampm, AMPM, dMod, th;
  var dateObject = this;
  YY = ((YYYY = dateObject.getFullYear()) + '').slice(-2);
  MM = (M = dateObject.getMonth() + 1) < 10 ? ('0' + M) : M;
  MMM = (MMMM = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][M - 1]).substring(0, 3);
  DD = (D = dateObject.getDate()) < 10 ? ('0' + D) : D;
  DDD = (DDDD = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][dateObject.getDay()]).substring(0, 3);
  th = (D >= 10 && D <= 20) ? 'th' : ((dMod = D % 10) == 1) ? 'st' : (dMod == 2) ? 'nd' : (dMod == 3) ? 'rd' : 'th';
  formatString = formatString
                .replace('#YYYY#', YYYY)
                .replace('#YY#', YY)
                .replace('#MMMM#', MMMM)
                .replace('#MMM#', MMM)
                .replace('#MM#', MM)
                .replace('#M#', M)
                .replace('#DDDD#', DDDD)
                .replace('#DDD#', DDD)
                .replace('#DD#', DD)
                .replace('#D#', D)
                .replace('#th#', th);

  h = (hhh = dateObject.getHours());
  if (h == 0) {
    h = 24;
  }
  if (h > 12) {
    h -= 12;
  }
  hh = h < 10 ? ('0' + h) : h;
  hhhh = hhh < 10 ? ('0' + hhh) : hhh;
  AMPM = (ampm = hhh < 12 ? 'am' : 'pm').toUpperCase();
  mm = (m = dateObject.getMinutes()) < 10 ? ('0' + m) : m;
  ss = (s = dateObject.getSeconds()) < 10 ? ('0' + s) : s;
  return formatString
        .replace('#hhhh#', hhhh)
        .replace('#hhh#', hhh)
        .replace('#hh#', hh)
        .replace('#h#', h)
        .replace('#mm#', mm)
        .replace('#m#', m)
        .replace('#ss#', ss)
        .replace('#s#', s)
        .replace('#ampm#', ampm)
        .replace('#AMPM#', AMPM);
}

// 获取URL参数
function GetRequest() {
  var url = window.location.search; //获取url中"?"符后的字串
  var theRequest = new Object();
  if (url.indexOf('?') != -1) {
    var str = url.substr(1);
    strs = str.split('&');
    for (var i = 0; i < strs.length; i ++) {
      theRequest[strs[i].split('=')[0]] = decodeURI(strs[i].split('=')[1]);
    }
  }
  return theRequest;
}

/**
 * 创建公用单独按钮alert提示框
 * 说明：可直接用createAlert()方法调用；
 * 其中message参数为必填参数，用来显示提示信息，
 * 示例：createAlert('数据错误！')；
 * opt和callback为选填参数：
 * opt默认为一个对象，也可为一个返回函数，当作为一个对象时，可设置提示框标题及按钮文字，
 * 示例：createAlert('数据错误！', {title: '请注意！', btn: '我知道了'})；
 * 当opt作为一个返回函数时，title和btn会有一个默认的显示，而后一个callback参数就没有必要再做设置。
 * 示例：createAlert('数据错误！', function(){……})；
 * callback默认为一个返回函数，作用于点击alert按钮后的操作。
 * 示例：createAlert('数据错误！', {title: '请注意！', btn: '我知道了'}, function(){……})；
 * .destroy()方法可用来隐藏提示框。
 */
var createAlert = function (message, opt, callback){
  if(window.BKBridge){
    var nopt={"msg":message};
    if (typeof opt === 'object'){
      nopt.data=opt;
    }
    show_alert(nopt, callback);
    return {};
  }
  var alertModal = new Object();
  alertModal.message = message;
  alertModal.opt = opt;
  alertModal.createHtml = function (){
    var html = '<div class="alert-modal">'
             + '<div class="modal-cover"></div>'
             + '<div class="modal-content">';
    if (typeof this.title !== 'undefined'){
      html += '<h5 class="modal-header">'+ this.title +'</h5>';
    } else {
      html += '<h5 class="modal-header">请注意</h5>';
    }
    if (typeof this.message !== 'undefined'){
      html += '<div class="modal-body">'+ this.message +'</div>';
    }
    if (typeof this.btn !== 'undefined'){
      html += '<div class="modal-footer"><div class="btn btn-confirm">'+ this.btn +'</div></div>';
    } else {
      html += '<div class="modal-footer"><div class="btn btn-confirm">确定</div></div>';
    }
    html += '</div></div>';
    return html;
  };
  alertModal.applyCallback = function (){
    if (typeof this.callback === 'function'){
      var fn = this.callback;
      fn();
    };
  };
  alertModal.createDom = function (){
    var dom = this.createHtml();
    this.modalDom = $(dom);
  };
  alertModal.setTitle = function (){
    var title = this.opt.title;
    if (typeof title === 'string') {
      // 定义title
      this.title = title;
    }
  };
  alertModal.setButton = function (){
    var btn = this.opt.btn;
    if (typeof btn === 'string') {
      // 定义btn
      this.btn = btn;
    }
  };
  alertModal.setCallback = function (fn){
    if (typeof fn === 'function') {
      // 定义callback
      this.callback = fn;
    }
  };
  alertModal.buildOpt = function (){
    if (typeof this.opt === 'object'){
      // 代表是title和btn对象
      this.setTitle();
      this.setButton();
    } else if (typeof this.opt === 'function'){
      // 代表opt是个callback
      this.setCallback(this.opt);
    }
  };
  alertModal.show = function (){
    // 编辑title配置
    this.buildOpt();
    // 设置callback参数
    this.setCallback(callback);
    this.createDom();
    this.bindClick();
    $('body').append(this.modalDom);
    this.modalDom.fadeIn().addClass('active');
  };
  alertModal.destroy = function (){
    this.modalDom.removeClass('active').fadeOut(function(){
      this.modalDom.remove();
    }.bind(this));
  };
  alertModal.bindClick = function (){
    this.modalDom.find('.modal-cover').click(function(){
      this.destroy();
    }.bind(this));
    this.modalDom.find('.btn-confirm').click(function(){
      this.destroy();
      this.applyCallback();
    }.bind(this));
  };
  alertModal.show();
};

/**
 * 创建公用确定、取消双按钮并有返回函数confirm提示框
 * 说明：可直接用createConfirm()方法调用；
 * 其中message参数为必填参数，用来显示提示信息，
 * 示例：createConfirm('您是否要继续？')；
 * opt和callback为选填参数：
 * opt默认为一个对象，也可为一个返回函数，当作为一个对象时，可设置提示框标题及两个按钮文字，
 * confirm来设置确定按钮，cancel来设置取消按钮：
 * 示例：createConfirm('您是否要继续？', {title: '请注意！', confirm: '好的', cancel: '否'})；这三个参数均为选填，当不设置时，均有默认文字显示。
 * 当opt作为一个返回函数时，title和btn都会有一个默认的显示，而后一个callback参数就没有必要再做设置。
 * 返回函数需要一个返回值来判定用户点击的是confirm还是cancel；
 * 示例：createConfirm('您是否要继续？', function(type){if(type == 'confirm'){'点击了是'};if(type == 'cancel'){'点击了否'}})；
 * callback默认为一个返回函数，作用于点击按钮后的操作，具体用法同上；
 * 示例：createConfirm('您是否要继续？', function(type){if(type == 'confirm'){'点击了是'};if(type == 'cancel'){'点击了否'}})；
 * .destroy()方法可用来隐藏提示框。
 */
var createConfirm = function (message, opt, callback){
  var confirmModal = new Object();
  confirmModal.message = message;
  confirmModal.opt = opt;
  confirmModal.createHtml = function (){
    var html = '<div class="alert-modal">'
             + '<div class="modal-cover"></div>'
             + '<div class="modal-content">';
    if (typeof this.title !== 'undefined'){
      html += '<h5 class="modal-header">'+ this.title +'</h5>';
    } else {
      html += '<h5 class="modal-header">请注意</h5>';
    }
    if (typeof this.message !== 'undefined'){
      html += '<div class="modal-body">'+ this.message +'</div>';
    } else {
      html += '<div class="modal-body">确认是否继续？</div>';
    }
    if (typeof this.cancel_btn !== 'undefined'){
      html += '<div class="modal-footer"><div class="btn btn-cancel">'+ this.cancel_btn +'</div>';
    } else {
      html += '<div class="modal-footer"><div class="btn btn-cancel">取消</div>';
    }
    if (typeof this.confirm_btn !== 'undefined'){
      html += '<div class="btn btn-confirm">'+ this.confirm_btn +'</div></div>';
    } else {
      html += '<div class="btn btn-confirm">确定</div></div>';
    }
    html += '</div></div>';
    return html;
  };
  confirmModal.createDom = function (){
    var dom = this.createHtml();
    this.modalDom = $(dom);
  };
  confirmModal.setTitle = function (){
    var title = this.opt.title;
    if (typeof title === 'string') {
      // 定义title
      this.title = title;
    }
  };
  confirmModal.setButton = function (){
    var confirm = opt.confirm;
    var cancel = opt.cancel;
    if (typeof confirm === 'string'){
      this.confirm_btn = confirm;
    }
    if (typeof cancel === 'string'){
      this.cancel_btn = cancel;
    }
  };
  confirmModal.setCallback = function (fn){
    if (typeof fn === 'function') {
      // 定义callback
      this.callback = fn;
    }
  };
  confirmModal.applyCallback = function (type){
    if (typeof this.callback === 'function'){
      var fn = this.callback;
      fn(type);
    };
  };
  confirmModal.buildOpt = function (){
    if (typeof this.opt === 'object'){
      // 代表是title和btn对象
      this.setTitle();
      this.setButton();
    } else if (typeof this.opt === 'function'){
      // 代表opt是个callback
      this.setCallback(this.opt);
    }
  };
  confirmModal.show = function (){
    // 编辑title配置
    this.buildOpt();
    // 设置callback参数
    this.setCallback(callback);
    this.createDom();
    this.bindClick();
    $('body').append(this.modalDom);
    this.modalDom.fadeIn().addClass('active');
  };
  confirmModal.destroy = function (){
    this.modalDom.removeClass('active').fadeOut(function(){
      this.modalDom.remove();
    }.bind(this));
  };
  confirmModal.bindClick = function (){
    this.modalDom.find('.modal-cover').click(function(){
      this.destroy();
    }.bind(this));
    this.modalDom.find('.btn-cancel').click(function(){
      this.destroy();
      this.applyCallback('cancel');
    }.bind(this));
    this.modalDom.find('.btn-confirm').click(function(){
      this.destroy();
      this.applyCallback('confirm');
    }.bind(this));
  };
  confirmModal.show();
};

// 构建对象
function buildObjData(key, value) {
  var obj = {};
  obj[key] = value;
  return obj;
}

// localstorage事件
function setLocalData(key, value) {
  var storage = window.localStorage;
  storage.setItem(key, JSON.stringify(value));
}

function getLocalData(key) {
  var storage = window.localStorage;
  return JSON.parse(storage.getItem(key));
}

function removeLocalData(key) {
  var storage = window.localStorage;
  storage.removeItem(key);
}

function clearLocalData() {
  var storage = window.localStorage;
  storage.clear();
}

// 只准输入数字
function keyboardOnlyNumber(){
  var keyCode = event.keyCode;
  if (keyCode >= 48 && keyCode <= 57) {
    event.returnValue = true;
  }else {
    event.returnValue = false;
  }
}

// 检查单数据是否为undefined
function checkData(data) {
  data = !!data ? data : '';
  return data;
}

// 用key获取数据
function keyGetData(data, key) {
  var result = {};
  if (data.key === key) {
    result.key = data.key;
    result.title = data.title;
    result.content = data.content;
  }
  return result;
}