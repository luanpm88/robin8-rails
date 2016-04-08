import React, { PropTypes } from 'react';
import { Link } from 'react-router';

export default class Overview extends React.Component{
  constructor(props, context){
    super(props, context);
  }

  render_total_count(campaign){
    return(
      <li><span className="txt">点击量</span><strong className="stat-num">{ campaign.get("total_click") }</strong></li>
    )
  }

  render_available_count(campaign){
    if (campaign.get("per_budget_type") == "cpa" || campaign.get("per_budget_type") == "click"){
      return(
        <li><span className="txt">有效点击</span><strong className="stat-num">{ campaign.get("total_click") }</strong></li>
      )
    }
    if (campaign.get("per_budget_type") == "post"){
      return(
        <li><span className="txt">转发量</span><strong className="stat-num">{ campaign.get("post_count") }</strong></li>
      )
    }
  }

  render(){
    const { campaign } = this.props
    return(
      <div className="panel activity-stat-bigshow-panel">
        <div className="panel-heading">
          <a href="#panelStatBigShow" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
          <h4 className="panel-title">总览</h4>
        </div>
        <div id="panelStatBigShow" className="panel-collapse collapse in">
          <div className="panel-body">
            <div className="activity-stat-bigshow-area">
              <ul>
                <li><span className="txt">已花费</span><strong className="stat-num"><sapn className="symbol">￥</sapn>{ campaign.get("take_budget") }</strong></li>
                <li><span className="txt">参与人数</span><strong className="stat-num">{ campaign.get("join_count") }</strong></li>
                { this.render_total_count(campaign) }
                { this.render_available_count(campaign) }
              </ul>
            </div>
          </div>
        </div>
      </div>
    )
  }
}