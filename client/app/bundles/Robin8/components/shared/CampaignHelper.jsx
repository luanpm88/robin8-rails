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