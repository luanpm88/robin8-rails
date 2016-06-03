import React, { Component } from 'react';
import { Link } from 'react-router';

import "campaign/activity/select.scss";
import BreadCrumb     from './shared/BreadCrumb';

class SelectCampaignPartial extends Component {
  render() {
    return (
      <div className="page page-activity page-activity-select">
        <div className="container">
          <BreadCrumb />
          <div className="at-s-top">
            <h2>新建推广活动</h2>
          </div>
          <div className="at-s-ls">
            <div className="at-s-box">
              <div className="at-box-hd">
                <div className="at-box-pic">
                  <img src={require('icon-light.png')} />
                </div>
                <h3>转发活动</h3>
              </div>
              <div className="at-box-ct">
                <p>转发活动包括：CPC（按点击计费的转发活动）</p>
                <p>CPA（按用户任务完成数量计费的转发活动）</p>
                <p>CPP（按转发次数计费的转发活动）</p>
              </div>
              <div className="at-box-bt">
                <Link to="/brand/campaigns/new" className="btn">
                  立即创建
                </Link>
              </div>
            </div>
            <div className="at-s-box">
              <div className="at-box-mk mk-new">
                <div className="mk-bg"></div>
                <i>NEW</i>
              </div>
              <div className="at-box-hd">
                <div className="at-box-pic">
                  <img src={require('icon-cup.png')} />
                </div>
                <h3>招募活动</h3>
              </div>

              <div className="at-box-ct">
                <p>招募活动采用KOL报名的形式，您只需填写您需</p>
                <p>要KOL完成的任务，这可以是一次线上活动或线</p>
                <p>下活动，我们将为您推送最合适的KOL参加。</p>
              </div>
              <div className="at-box-bt">
                <Link to="/brand/recruits/new" className="btn">
                  立即创建
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default SelectCampaignPartial;
