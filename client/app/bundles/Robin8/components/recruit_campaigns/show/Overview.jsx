import React, { PropTypes } from 'react';
import { Link } from 'react-router';
import _ from 'lodash';

export default class Overview extends React.Component{
  constructor(props, context){
    super(props, context);
  }

  render_total_count(campaign){
    return(
      <li><span className="txt">点击数</span><small className="stat-num">{ campaign.get("total_click") }</small></li>
    )
  }

  render_available_count(campaign){
    if (campaign.get("per_budget_type") == "cpa" || campaign.get("per_budget_type") == "click"){
      return(
        <li><span className="txt">计费点击</span><small className="stat-num">{ campaign.get("avail_click") }</small></li>
      )
    }
    if (campaign.get("per_budget_type") == "post"){
      return(
        <li><span className="txt">转发量</span><small className="stat-num">{ campaign.get("post_count") }</small></li>
      )
    }
  }

  render(){
    const { campaign } = this.props

    return(
      <div className="panel activity-stat-bigshow-panel">
        <div id="panelStatBigShow" className="panel-collapse collapse in">
          <div className="panel-body">
            <div className="activity-stat-bigshow-area grid-3">
              <ul>
                <li><span className="txt">预计招募人数</span><small className="stat-num">{ campaign.get("recruit_person_count") }</small></li>
                <li><span className="txt">人均奖励</span><small className="stat-num stat-yuan"><sapn className="symbol">￥</sapn>{ campaign.get("per_action_budget") }</small></li>
                <li><span className="txt">招募预算</span><small className="stat-num stat-yuan"><sapn className="symbol">￥</sapn>{ campaign.get("budget") }</small></li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
