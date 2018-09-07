/**
 * 密码框，类似支付宝支付密码框。
 */
(function($) {
  $.fn.extend({
    pwd: function(action) {
      var target = this;

      function initPwdInput(target) {
        var $target = $(target);
        var $parent = $target.parent();
        var container_width = $parent.outerWidth();
        var max_length = $target.attr('maxlength');

        var $pwd_input = $('<div class="password-input-container"></div>');
        // var $pwd_item = $('<div class="password-input-item"></div>');

        for (var i = max_length - 1; i >= 0; i--) {
          $pwd_input.append('<div class="password-input-item"></div>');
        }

        var $pwd_item = $pwd_input.find('.password-input-item');

        $pwd_item.each(function(index, el) {
          var $item = $(el);
          $item.css({
            width: container_width / max_length,
            height: container_width / max_length,
            lineHeight: container_width / max_length + 'px'
          });

          $item.click(function(event) {
            $target.focus();
          });
        });

        $target.on('keyup change', function(event) {
          var $that = $(this);
          var _val = $that.val();
          console.log(_val);
          $pwd_item.html('');
          for (var i = _val.length - 1; i >= 0; i--) {
            $pwd_item.eq(i).html(_val[i]);
          }
        });

        $parent.append($pwd_input);
      }

      switch (action) {
        case 'init':
          {
            initPwdInput(this);
            break;
          }
      }

      return this;
    }
  })
})(jQuery);
