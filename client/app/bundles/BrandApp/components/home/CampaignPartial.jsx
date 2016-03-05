import React from 'react';
import moment from 'moment';

export default class CampaignPartial extends React.Component {
  render() {
    return (
      <div className="panel my-activities-panel">
        <div className="panel-heading">
          <a href="#panelActivities" data-toggle="collapse" className="switch">
            <span className="txt">收起</span>
            <i className="caret-arrow" />
          </a>
          <a href="/react/create_activity" target="_blank" className="btn btn-blue btn-big quick-btn">
            添加推广活动
          </a>
          <h4 className="panel-title">
            我的推广活动
            <span className="carte">/</span>
            <strong className="stat-num">{
              this.props.$$Campaign.get('readyState') == 'request' ?
              "请求中....." :
              this.props.$$Campaign.get('items').size
            }</strong>
          </h4>
        </div>
        <div id="panelActivities" className="panel-collapse collapse in">
          <div className="panel-body">

            {this.props.$$Campaign.get('items').map(function(campaign, index) {
              return <div className="brand-activity-card" key={index}>
                <div className="brand-activity-content">
                  <a href="brand_activity_detail.html" className="detail-link">
                    &gt;
                  </a>
                  <h2 className="activity-title">
                    { campaign.get('name') }
                  </h2>
                  <small className="date">
                    { moment(campaign.get('start_time')).format("D.M.YYYY") }
                  </small>
                  <div className="summary">
                    { campaign.get('description') }
                  </div>
                  <a href="#" className="link">
                    { campaign.get('url') }
                  </a>
                  <ul className="stat-info grid-4">
                    <li>
                      <span className="txt">已花费</span>
                      <strong className="stat-num">
                        <sapn className="symbol">{ campaign.get('currency') }</sapn>
                        { campaign.get('cost') }
                      </strong>
                    </li>
                    <li>
                      <span className="txt">参与人数</span>
                      <strong className="stat-num">{ campaign.get('participators_count') }</strong>
                    </li>
                    <li>
                      <span className="txt">点击率</span>
                      <strong className="stat-num">789895544</strong>
                    </li>
                    <li>
                      <span className="txt">剩余天数</span>
                      <strong className="stat-num">{ campaign.get('remaining_days') }</strong>
                    </li>
                  </ul>
                </div>
                <div className="brand-activity-coverphoto pull-left"><img src={ require("temp/activity.jpg") } alt="可口可乐带你过新年" /></div>
              </div>;
            })}

          </div>
        </div>
      </div>
    );
  }
}
