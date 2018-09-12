var verify_phone = /^(0|86|17951)?(13[0-9]|15[012356789]|17[0-9]|18[0-9]|14[57])[0-9]{8}$/;  // 手机号码验证
var verify_email = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; // email校验
var verify_pw = /^\d{6}$/; //密码校验，6位数字

var SERVERHOST = $('#host_url').val();
// var SERVERHOST = 'http://192.168.51.170:3000/';
// var URLHOST = 'http://pdms2.robin8.io';
var URLHOST = 'https://pmes.robin8.io';

// 判断复选框是否被选中，改变button状态
function judgeChecked(checkbox, button) {
  if (!checkbox.is(':checked')) {
    button.attr('disabled', true);
  } else {
    button.attr('disabled', false);
  }
}

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

function PMESCtrl(password) {
  this.password = password;

  this.create = PMES.create(this.password);
  this.token = this.create.token;
  this.public_key = this.create.public_key;
  this.mnemonic = this.create.mnemonic;
  this.signature = '';
  this.error_tips = '';
}

PMESCtrl.prototype = {
  constructor: PMESCtrl,
  sign: function() {
    var current_date = new Date();
    current_date = current_date.customFormat('#YYYY##MM##DD##hhh##mm#');
    var that = this;
    var pmes_sign = PMES.sign(
      that.token,
      {
        'message': {
          'email': '', // Robin8用户电子邮件
          'phone': '', // Robin8用户电话
          'device_id': '', // Robin8用户device_id
          'timestamp': current_date // 当前201808091319, 格式 YYYYMMDDHHmm
        }
      },
      that.password
    );

    if (Object.keys(pmes_sign).indexOf('error') > -1) {
      that.error_tips = 'invaild token or password';
      return false;
    }
    that.signature = pmes_sign.signature;
  }
}
