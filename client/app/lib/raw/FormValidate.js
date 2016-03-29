import validator from 'validator';

global.FormValidate = function(options){
  return (values) => {
    const errors = {}

    Object.keys(options).map((fieldName) => {
      const fieldOption = options[fieldName];
      const value = values[fieldName];

      if (fieldOption.require && !value) {
        // require

        const val = fieldOption.require;
        errors[fieldName] = (val === true ? '该选项为必填项' : val);
      } else if (value && fieldOption.url && !validator.isURL(value, fieldOption.url)) {
        // url

        const val = fieldOption.url.message;
        errors[fieldName] = (val ? val : '必须是超链接, 以 http:// 或 https://开头');
      } else if (value && fieldOption.email && !validator.isEmail(value)) {
        errors[fieldName] = "邮箱格式不正确";
      } else if (fieldName == 'budget' && value) {
        if(parseInt(value) > parseInt($(".budget-input").attr("brand-amount"))){
          errors[fieldName] = "账户余额不足, 请充值";
        }

        fetch('/brand_api/v1/user', { credentials: 'same-origin' })
          .then(function(response){
            response.json().then(function(data){
              $(".budget-input").attr("brand-amount", parseInt(data.avail_amount))
            })
          })

        if (value < fieldOption.min_budget) {
          errors[fieldName] = "最低费用100元";
        }
      } else if (fieldName == 'per_action_budget' && value) {
        if ($("input:radio:checked").val() === 'click' && parseFloat(value) < 0.1) {
          errors[fieldName] = "最低金额为 0.1 元";
        } else if ($("input:radio:checked").val() === 'post' && parseFloat(value) < 2) {
          errors[fieldName] = "最低金额为 2 元";
        } else if ($("input:radio:checked").val() == 'cpa' && parseFloat(value) < 1) {
          errors[fieldName] = "最低金额为 1 元";
        } else if (parseFloat(value) > parseInt($(".budget-input").val())) {
          errors[fieldName] = "单次预算不能大于总预算";
        }
      } else if ( fieldName === 'action_url' || fieldName === 'short_url') {
        if ($("input:radio:checked").val() === 'cpa') {
          if (!value) {
            errors[fieldName] = "该选项为必填项";
          } else if (value && !validator.isURL(value, fieldOption.url)) {
            const val = fieldOption.cpa_url.message;
            errors[fieldName] = (val ? val : '必须是超链接, 以 http:// 或 https://开头');
          }
        }
      }
      else if(fieldName === "new_password_confirmation") {
        if(value !== $('#new_password').val()) {
          errors[fieldName] = "确认密码和新密码不一致";
        }
      }
      else if(fieldName === 'new_password' || fieldName === 'password' || fieldName === 'new_password_confirmation') {
        if(value.length < fieldOption.min_length) {
          errors[fieldName] = "密码最少为6位"
        }
      }
    })

    return errors;
  }
}
