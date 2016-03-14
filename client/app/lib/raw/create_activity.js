/*
 * 创建品牌活动JS
 * 02.15.2016
*/
export default function createActivity () {
  // 关闭或刷新该页面时提示
  // 防止用户误关闭页面而重新填写
  $(window).bind('beforeunload', function() {
    var T = $('.activity-title-input').val().length,
        I = $('.activity-intro-input').val().length,
        C = $('.creat-content-sources input[type="text"]').val().length;
    if ( T != 0 || I != 0 || C != 0 ) return '您填写的信息将不被保存！';
  });

  // 输入字数限制
  // bootstrap-maxlength
  // https://github.com/mimo84/bootstrap-maxlength/
  $('.activity-title-input, .activity-intro-input').maxlength({
    placement: 'centered-right',
    appendToParent: '.form-group'
  });


  // 媒体关键词
  // bootstrap-tagsinput
  // https://github.com/bootstrap-tagsinput/bootstrap-tagsinput
  $('.activity-keywords-input').tagsinput({
    maxTags: 5,
    allowDuplicates: false, //关键词不能重复
    confirmKeys: [13, 32] // 回车或空格确认输入
  });

  // 关键词满5个提示
  $('.activity-keywords-input').on({'itemAdded':function(event){
    var tips = '<span class="label label-danger">最多输入5个关键词</span>';
    if ( $('.bootstrap-tagsinput').hasClass('bootstrap-tagsinput-max') ) {
      $(this).parent().append( tips );
      //console.log('5个了')
    }
  },'itemRemoved':function(event){
      $(this).siblings('.label-danger').remove();
    }
  });


  // 推广预算
  // bootstrap-touchspin
  // https://github.com/istvan-ujjmeszaros/bootstrap-touchspin
  $('.spinner-input').TouchSpin({
    min: 1000,
    max: 10000000,
    prefix: '$'
  });

  // 日期控件
  // bootstrap-datepicker
  // https://github.com/eternicode/bootstrap-datepicker
  function currentDate(){
    var curDate = new Date(),
        yyyy = curDate.getFullYear(),
        mm   = curDate.getMonth()+1,
        d    = curDate.getDate();

    if(mm < 10) mm = '0' + mm;

    var str = yyyy + '/' + mm + '/' + d;
    return str;
  }

  // 显示当天日期
  $('.date-range-form-area input').val(currentDate());
  $('.input-daterange').datepicker({
    format: 'yyyy/mm/dd',
    startDate: '',
    autoclose: true,
    startDate: new Date(),
    language: 'zh-CN'
  });
}