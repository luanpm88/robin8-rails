import React from 'react';
/*import InfluencePartial from './home/InfluencePartial';*/
/*import MediaPartial from './home/MediaPartial';*/

import "home.css";

export default class HomePartial extends React.Component {
  render() {
    return (
      <div>
        <header className="brand-header">
          <div className="container-fluid">
            <div className="brand-logo"><img src={ require("temp/brand_logo.png") } /></div>
            <div className="brand-menu">
              <div className="dropdown">
                <a href="#" className="brand-name" data-toggle="dropdown">{this.props.$$CurrentUser.get('name')}<i className="caret-arrow" /></a>
                <ul className="dropdown-menu">
                  <li><a href="#">Action</a></li>
                </ul>
              </div>
            </div>
          </div>
        </header>
        <div className="wrapper">
          <div className="container">
            {/*<InfluencePartial />*/}
            {/*<MediaPartial />*/}
            {/* 我的推广活动 S */}
            <div className="panel my-activities-panel">
              <div className="panel-heading">
                <a href="#panelActivities" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
                <a href="create_activity.html" target="_blank" className="btn btn-blue btn-big quick-btn">添加推广活动</a>
                <h4 className="panel-title">我的推广活动<span className="carte">/</span><strong className="stat-num">7</strong></h4>
              </div>
              <div id="panelActivities" className="panel-collapse collapse in">
                <div className="panel-body">
                  {/* 一条活动 正在进行的 S */}
                  <div className="brand-activity-card">
                    <div className="brand-activity-content">
                      <a href="brand_activity_detail.html" className="detail-link">&gt;</a>
                      <h2 className="activity-title">可口可乐带你过新年</h2>
                      <small className="date">01.27.2016</small>
                      <div className="summary">转发有奖，有大奖。可乐管够！</div>
                      <a href="#" className="link">www.cocacola.com</a>
                      <ul className="stat-info grid-4">
                        <li><span className="txt">已花费</span><strong className="stat-num"><sapn className="symbol">$</sapn>123</strong></li>
                        <li><span className="txt">参与人数</span><strong className="stat-num">69876</strong></li>
                        <li><span className="txt">点击率</span><strong className="stat-num">789895544</strong></li>
                        <li><span className="txt">剩余天数</span><strong className="stat-num">2</strong></li>
                      </ul>
                    </div>
                    <div className="brand-activity-coverphoto pull-left"><img src={ require("temp/activity.jpg") } alt="可口可乐带你过新年" /></div>
                  </div>
                  {/* 一条活动 正在进行的 E */}
                  {/* 一条活动 结束的 S */}
                  {/* 已结束的活动追加 class:closure */}
                  <div className="brand-activity-card closure">
                    <div className="brand-activity-content">
                      <a href="brand_activity_detail.html" className="detail-link">&gt;</a>
                      <h2 className="activity-title">可口可乐带你过新年</h2>
                      <small className="date">01.27.2016</small>
                      <div className="summary">转发有奖，有大奖。可乐管够！</div>
                      <a href="#" className="link">www.cocacola.com</a>
                      <ul className="stat-info grid-4">
                        <li><span className="txt">已花费</span><strong className="stat-num"><sapn className="symbol">$</sapn>123</strong></li>
                        <li><span className="txt">参与人数</span><strong className="stat-num">69876</strong></li>
                        <li><span className="txt">点击率</span><strong className="stat-num">789895544</strong></li>
                        <li><span className="txt">剩余天数</span><strong className="stat-num">2</strong></li>
                      </ul>
                    </div>
                    <div className="brand-activity-coverphoto pull-left"><img src={ require("temp/activity.jpg") } alt="可口可乐带你过新年" /></div>
                  </div>
                  {/* 一条活动 结束的 E */}
                </div>
              </div>
            </div>
            {/* 我的推广活动 E */}
          </div>
        </div>
      </div>
    );
  }
}