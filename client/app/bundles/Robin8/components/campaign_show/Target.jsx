import React, { PropTypes } from 'react';
import Link from "react-router";

import { ageHelper, genderHelper } from "../../helpers/CampaignHelper"

export default class Target extends React.Component{
  constructor(props, context){
    super(props, context);
  }

  render(){
    const { campaign } = this.props;
    return(
      <div className="panel activity-target-bigshow-panel">
        <div className="panel-heading">
          <a href="#panelTargetShow" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
          <h4 className="panel-title">推广目标</h4>
        </div>
        <div id="panelTargetShow" className="pannel-collapse  collapse in">
          <div className="pannel-body">
            <div className="activity-target-bigshow-area">
              <ul>
                <li><span className="txt">年龄段</span><strong className="stat-num">{ ageHelper(campaign.get("age"))}</strong></li>
                <li><span className="txt">地区</span><strong className="stat-num">{ campaign.get("province") }-{campaign.get("city")}</strong></li>
                <li><span className="txt">性别</span><strong className="stat-num">{ genderHelper(campaign.get("gender")) }</strong></li>
              </ul>
            </div>
            <div className="activity-message-bigshow-area">
              <div className="message_label">KOL留言</div>
              <div className="message_show"><span>{campaign.get("message")}</span></div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}