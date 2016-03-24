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
        errors[fieldName] = (val === true ? '必填' : val);
      } else if (value && fieldOption.url && !validator.isURL(value, fieldOption.url)) {
        // url

        const val = fieldOption.url.message;
        errors[fieldName] = (val ? val : '必须是超链接');
      } else if (fieldName == 'budget' && value){
        if(value > parseInt($(".budget-input").attr("brand-amount"))){
          errors[fieldName] = "账户余额不足, 请充值";
        }

        promise: fetch(`/users/get_avail_amount`, { credentials: 'included' })
          .then(function(response){
            response.json().then(function(data){
              $(".budget-input").attr("brand-amount", parseInt(data["avail_amount"]))
            })
          }
        )

        if (value < fieldOption.min_budget) {
          errors[fieldName] = "最低费用100元";
        }
      } else if (fieldName == 'per_action_budget' && value) {
        if ($("input:radio:checked").val() === 'click' && value < 0.1) {
          errors[fieldName] = "最低金额为 0.1 元";
        }
        else if ($("input:radio:checked").val() === 'post' && value < 2) {
          errors[fieldName] = "最低金额为 2 元";
        }
        else if ($("input:radio:checked").val() == 'cpa' && value < 1) {
          errors[fieldName] = "最低金额为 1 元";
        }
        else if (value > $(".budget-input").val()) {
          errors[fieldName] = "单次预算不能大于总预算";
        }
      }
    })

    return errors;
  }
}
