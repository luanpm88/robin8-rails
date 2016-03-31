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

export function formatDate(date, format="YYYY-M-D h:mm"){
  return moment(date).format(format)
}

export function ageHelper(age){
  switch(age){
    case "all":
      return "全部"
    case "baby":
      return "0-5岁"
    case "children":
      return "5-10岁"
    case "young":
      return "10-20岁"
    case "man":
      return "20-40岁"
    case "middle_age":
      return "40-60岁"
    case "old":
      return "60岁以上"
    default:
      return "全部"
  }
}

export function genderHelper(gender){
  switch(gender){
    case "all":
      return "全部"
    case "male":
      return "男"
    case "female":
      return "女"
    default:
      return "全部"

  }
}


export function campaignStatusHelper(status){
  const img_name = `campaign_${status}.png`
  
  }
}