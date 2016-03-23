import validator from 'validator';

global.FormValidate = function(options){
  return (values) => {
    const errors = {}

    Object.keys(options).map((fieldName) => {
      const fieldOption = options[fieldName];
      const value = values[fieldName];

      if(fieldOption.require && !value) {
        // require

        const val = fieldOption.require;
        errors[fieldName] = (val === true ? '必填' : val);
      } else if(value && fieldOption.url && !validator.isURL(value, fieldOption.url)) {
        // url

        const val = fieldOption.url.message;
        errors[fieldName] = (val ? val : '必须是超链接');
      }
    })

    return errors;
  }
}
