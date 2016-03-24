import React, { PropTypes } from 'react';
import { Link } from 'react-router';

export default class Overview extends React.Component{
  constructor(props, context){
    super(props, context);
  }

  render(){
    <div className="panel activity-stat-bigshow-panel">
      <div className="panel-heading">
        <a href="#panelStatBigShow" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
        <h4 className="panel-title">总览</h4>
      </div>
      <div id="panelStatBigShow" className="panel-collapse collapse in">
        <div className="panel-body">
          {/* 活动数据总览大 S */}
          <div className="activity-stat-bigshow-area">
            <ul>
              <li><span className="txt">已花费</span><strong className="stat-num"><sapn className="symbol">$</sapn>{ campaign.get("per_budget_type") }</strong></li>
              <li><span className="txt">参与人数</span><strong className="stat-num">{ campaign.get("per_budget_type") }</strong></li>
              <li><span className="txt">点击量</span><strong className="stat-num">{ campaign.get("per_budget_type") }</strong></li>
              <li><span className="txt">剩余天数</span><strong className="stat-num">{ campaign.get("per_budget_type") }</strong></li>
            </ul>
          </div>
          {/* 活动数据总览大 E */}
        </div>
      </div>
    </div>
  }
}