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
      }
    });
    return errors;
  }
}
