import React, { PropTypes } from 'react';

export default class Overview extends React.Component{
  constructor(props, context){
    super(props, context);
  }

  render(){
    const { campaign } = this.props

    return(
      <div className="panel activity-stat-bigshow-panel">
        <div id="panelStatBigShow" className="panel-collapse collapse in">
          <div className="panel-body">
            <div className="activity-stat-bigshow-area grid-3">
              <ul>
                <li><span className="txt">预计邀请人数</span><small className="stat-num">{ campaign.get("total_invite_kols_count") }</small></li>
                <li><span className="txt">已邀请人数</span><small className="stat-num">{ campaign.get("total_agreed_invite_kols_count") }</small></li>
                <li><span className="txt">总预算</span><small className="stat-num stat-yuan"><sapn className="symbol">￥</sapn>{ campaign.get("budget") }</small></li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
