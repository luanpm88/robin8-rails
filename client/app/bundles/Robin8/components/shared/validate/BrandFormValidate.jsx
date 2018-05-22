import validator from 'validator';

export default function BrandFormValidate(options) {
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
        const val = fieldOption.url.message;
        errors[fieldName] = (val ? val : '链接格式错误');
      } else if (fieldName === "new_password_confirmation") {
        if (value !== $('#new_password').val()) {
          errors[fieldName] = "确认密码和新密码不一致";
        }
      } else if (fieldName === 'new_password' || fieldName === 'password' || fieldName === 'new_password_confirmation') {
        if (value.length < fieldOption.min_length) {
          errors[fieldName] = "密码最少为6位"
        }
      }
    })
    return errors;
  }

}
