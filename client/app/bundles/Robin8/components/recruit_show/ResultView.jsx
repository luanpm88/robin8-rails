import React, { PropTypes } from 'react';
import { Link } from 'react-router';

export default class ResultView extends React.Component{
  constructor(props, context){
    super(props, context);
  }

  render() {
    const { campaign } = this.props;

    return(
      <div className="panel activity-result-stat-bigshow-panel">
        <div id="panelResultBigShow" className="panel-collapse collapse in">
          <div className="panel-body">
            <div className="activity-stat-bigshow-area grid-3">
              <ul>
                <li><span className="txt">实际招募人数</span><small className="stat-num">{ campaign.get("brand_passed_count") }</small></li>
                <li><span className="txt">完成任务人数</span><small className="stat-num">{ campaign.get("total_finished_kols") }</small></li>
                <li><span className="txt">已支付预算</span><small className="stat-num stat-yuan"><sapn className="symbol">￥</sapn>{ campaign.get("take_budget") }</small></li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    );
  }
}