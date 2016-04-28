import moment from 'moment';
import React from 'react';

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

export function formatDate(date, format="YYYY-M-D H:mm"){
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
  switch(status){
    // 审核中
    case "unexecute":
    case "pending":
      return(<img className="campaign-status-img" src={ require('campaign-unexecute.png') } />)
    // 即将执行
    case "coming":
    case "agreed":
      return(<img className="campaign-status-img" src={ require('campaign-agreed.png') } />)
    // 报名中
    case "inviting":
      return(<img className="campaign-status-img" src={ require('campaign-inviting.png') } />)
    // 报名结束
    case "choosing":
      return(<img className="campaign-status-img" src={ require('campaign-applied.png') } />)
    // 执行中
    case "executing":
    case "running":
      return(<img className="campaign-status-img" src={ require('campaign-executing.png') } />)
    // 结算中
    case "settling":
    case "executed":
      return(<img className="campaign-status-img" src={ require('campaign-executed.png') } />)
    // 已完成
    case "settled":
      return(<img className="campaign-status-img" src={ require('campaign-settled.png') } />)
    // 拒绝
    case "rejected":
      return(<img className="campaign-status-img" src={ require('campaign-rejected.png') } />)
  }
}

export function canEditCampaign(status){
  switch(status){
    case "unexecute":
      return true
    default:
      return false
  }
}

export function isRecruitCampaign(per_budget_type){
  return per_budget_type === 'recruit' ? true : false;
}