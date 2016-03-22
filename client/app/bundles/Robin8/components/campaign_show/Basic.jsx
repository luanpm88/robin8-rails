import React, { PropTypes } from "react";
import DateFormater from "../shared/DateHelper";

export default class Basic extends React.Component {
  constructor(props, context){
    super(props, context)
  }
  render(){
    const { campaign } = this.props

    return (
      <div className="brand-activity-card brand-activity-card-detail">
        <div className="brand-activity-content">
          <a href="#" className="btn btn-default btn-red btn-line stop-btn">编辑</a>
          <h2 className="activity-title">{ campaign.get("name") }</h2>
          <small className="date">创建于: { DateFormater(campaign.get("created_at")) } </small>
          <div className="summary">{ campaign.get("desc") }</div>
          <a href="#" className="link">{ campaign.get("url") }</a>
          <ul className="stat-info grid-3">
            <li><span className="txt">时间</span><small className="date">{ DateFormater(campaign.get("created_at")) } - { DateFormater(campaign.get("deadline ")) }</small></li>
            <li><span className="txt">保证金</span><strong className="stat-num"><sapn className="symbol">$</sapn>{ campaign.get("per_budget_type") }</strong></li>
            <li><span className="txt">一次点击</span><strong className="stat-num"><sapn className="symbol">$</sapn>{ campaign.get("per_budget_type") }</strong></li>
          </ul>
        </div>
        <div className="brand-activity-coverphoto pull-left">
          <img src={ campaign.get("img_url") } alt={ campaign.get("name") } />
        </div>
      </div>
    );
  }  
}