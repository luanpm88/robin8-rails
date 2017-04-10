import validator from 'validator';

export default function EvaluateCampaignFormValidate(options){
  return (values) => {
    const errors = {}

    Object.keys(options).map((fieldName) => {
      const fieldOption = options[fieldName];
      const value = values[fieldName];

      if (fieldOption.require && !value) {
        // require
        const val = fieldOption.require;
        errors[fieldName] = (val === true ? '该选项为必填项' : val);
      }else if (fieldName == 'review_content' && value.length < 10){
        errors[fieldName] = "评价内容至少10个字";
      }else if (fieldName == 'review_content' && value.length > 500){
        errors[fieldName] = "评价内容不能超过500个字";
      }
    });
    return errors;
  }
}
