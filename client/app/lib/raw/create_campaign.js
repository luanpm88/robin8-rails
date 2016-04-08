/*
 * 创建品牌活动JS
 * 02.15.2016
*/

export default function createActivity () {
  // 输入字数限制
  // bootstrap-maxlength
  // https://github.com/mimo84/bootstrap-maxlength/
  $('.activity-title-input').maxlength({
    threshold: 21,
    placement: 'centered-right',
    appendToParent: '.form-group'
  });

  $('.activity-intro-input').maxlength({
    threshold: 139,
    placement: 'centered-right',
    appendToParent: '.form-group'
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
          //alert("Your browser doesn't support file upload!");
        }
      });
    };
  };

  // 图片上传预览
  $('#coverPhotoPlaceholder').previewImage({
    uploader: '#coverUpload'
  });
}
