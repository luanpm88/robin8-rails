import moment from 'moment';

export function showCampaignTypeText(budget_type){
  switch(budget_type){
    case "click":
      return "点击"
    case "cpa":
      return "行动"
    case  "post":
      return "转发"
  }
}

export function formaDate(date, format="YYYY-M-D h:mm"){
  return moment(date).format(format)
}