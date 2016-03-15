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

  $('.target-city-selector').CitySelector();

  // 推广预算
  // bootstrap-touchspin
  // https://github.com/istvan-ujjmeszaros/bootstrap-touchspin
  $('.spinner-input').TouchSpin({
    min: 0,
    max: 10000000,
    prefix: '￥'
  });

  // 日期控件
  // bootstrap-datepicker
  // https://github.com/eternicode/bootstrap-datepicker
  var now = new Date
  var start_time = new Date(now.setHours(now.getHours() + 2));
  var deadline = new Date(now.setDate(now.getDate() + 2));

  var datepickerStartOptions = {
    ignoreReadonly: true,
    locale: 'zh-cn',
    format: 'YYYY-MM-DD HH:mm',
    defaultDate: start_time
  }

  var datepickerEndOptions = {
    ignoreReadonly: true,
    locale: 'zh-cn',
    format: 'YYYY-MM-DD HH:mm',
    useCurrent: false,
    defaultDate: deadline
  }

  $('#start-time-datepicker').datetimepicker(datepickerStartOptions);
  $('#deadline-datepicker').datetimepicker(datepickerEndOptions);
  $("#start-time-datepicker").on("dp.change", function (e) {
    $('#deadline-datepicker').data("DateTimePicker").minDate(e.date);
  });
  $("#deadline-datepicker").on("dp.change", function (e) {
      $('#start-time-datepicker').data("DateTimePicker").maxDate(e.date);
  });


  // image upload previewer
  $.fn.previewImage = function(options) {
    var previewer = new ImagePreviewer(this, options.uploader);
        previewer.perform();
  };

  function ImagePreviewer(placeholder, uploader) {
    this.perform = function() {
      $(placeholder).click(function() {
        $(uploader).trigger('click');
      });

      $(uploader).change(function(e) {
        var files = e.target.files;
        if(FileReader && files && files.length) {
          var reader = new FileReader();
          reader.onload = function() {
            placeholder[0].src = reader.result;
          };
          reader.readAsDataURL(files[0]);
        }
        else {
          alert("Your browser doesn't support file upload!");
        }
      });
    };
  };

  // 图片上传预览
  $('#coverPhotoPlaceholder').previewImage({
    uploader: '#coverUpload'
  });

  // per budget 类型选择
  $('input:radio[name="action_type"]').filter('[value=click]').click(function(){
    $(".action-url-group").hide()
  })
  $('input:radio[name="action_type"]').filter('[value=post]').click(function() {
    $(".action-url-group").hide()
  })
  $('input:radio[name="action_type"]').filter('[value=action]').click(function() {
    $(".action-url-group").show()
  })
}
