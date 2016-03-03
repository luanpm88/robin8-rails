import React from 'react';
import "home.css";

export default class HomePartial extends React.Component {
  render() {
    return (

      <div className="wrapper">
        <div className="container">
          {/* 我的品牌影响力 S */}
          <div className="panel my-linfluence-panel">
            <div className="panel-heading">
              <a href="#paneLinfluence" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
              <h4 className="panel-title">我的品牌影响力</h4>
            </div>
            <div id="paneLinfluence" className="panel-collapse collapse in">
              <div className="panel-body">
                <p className="infl-stat-info">在过去的<strong className="stat-num">24</strong>小时内，被提及<strong className="stat-num">123456789</strong>次</p>
                {/* 引入品牌影响力组件 */}
                {/* 品牌影响力组件 S */}
                <div className="brand-influence-area">
                  {/* 图表 S */}
                  <div className="infographic-influence-box">
                    <div className="infographic-show clearfix">
                      <p className="stat stat-good">
                        <i className="icon-good">赞</i>
                        <strong className="stat-num">70<i>%</i></strong><span className="txt">认为你很赞</span>
                      </p>
                      <div className="inf-show inf-good" style={{width: '70%'}} />
                      <div className="inf-show inf-bad" style={{width: '30%'}} />
                      <p className="stat stat-bad">
                        <i className="icon-bad">烂</i>
                        <span className="txt">认为你很烂</span><strong className="stat-num">30<i>%</i></strong>
                      </p>
                    </div>
                  </div>
                  {/* 图表 E */}
                  {/* 标签云 S */}
                  <div className="tags-influence-box clearfix">
                    <div id="tagsGoodBox" className="tags-box pull-left jqcloud" style={{width: 260, height: 100}}><span id="tagsGoodBox_word_0" className="w10" style={{position: 'absolute', left: 100, top: '32.5px'}}>经典</span><span id="tagsGoodBox_word_2" className="w10" style={{position: 'absolute', left: '172.358px', top: '35.5821px'}}>时尚</span><span id="tagsGoodBox_word_3" className="w7" style={{position: 'absolute', left: '50.6879px', top: '54.7356px'}}>激情</span><span id="tagsGoodBox_word_4" className="w4" style={{position: 'absolute', left: '130.389px', top: '13.6327px'}}>好喝</span><span id="tagsGoodBox_word_5" className="w1" style={{position: 'absolute', left: '17.0914px', top: '46.0931px'}}>温情</span></div>
                    <div id="tagsBadBox" className="tags-box pull-right jqcloud" style={{width: 260, height: 100}}><span id="tagsBadBox_word_0" className="w10" style={{position: 'absolute', left: 85, top: '32.5px'}}>高热量</span><span id="tagsBadBox_word_1" className="w7" style={{position: 'absolute', left: '121.814px', top: '5.55139px'}}>咖啡因</span><span id="tagsBadBox_word_2" className="w4" style={{position: 'absolute', left: '47.4043px', top: '40.7069px'}}>太甜</span><span id="tagsBadBox_word_3" className="w1" style={{position: 'absolute', left: '125.203px', top: '74.7728px'}}>难喝</span></div>
                  </div>
                  {/* 标签云 E */}
                </div>
                {/* 品牌影响力组件 E */}
                <a href="#" className="btn btn-grey btn-big btn-line center-block">查看详情</a>
              </div>
            </div>
          </div>
          {/* 我的品牌影响力 E */}
          {/* 我的御用媒体 S */}
          <div className="panel my-medias-panel">
            <div className="panel-heading">
              <a href="#panelMedias" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
              <a href="#" target="_blank" className="btn btn-blue btn-big quick-btn">认识新的自媒体</a>
              <h4 className="panel-title">我的御用媒体<i className="carte">/</i><strong className="stat-num">5698</strong></h4>
            </div>
            <div id="panelMedias" className="panel-collapse collapse in">
              <div className="panel-body">
                <div className="medias-area">
                  {/* 媒体人列表 S */}
                  <ul className="medias-list">
                    <li className="media-item">
                      <a href="#">
                        <img src={ require("temp/avater1.jpg") } className="avater-small" alt="艾米莉 布朗特" />
                        <span className="txt">艾米莉 布朗特</span>
                      </a>
                    </li>
                    <li className="media-item">
                      <a href="#">
                        <img src={ require("temp/avater2.jpg") } className="avater-small" alt="Michael Caine" />
                        <span className="txt">Michael Caine</span>
                      </a>
                    </li>
                    <li className="media-item">
                      <a href="#">
                        <img src={ require("temp/avater3.jpg") } className="avater-small" alt="Natalie Portman" />
                        <span className="txt">Natalie Portman</span>
                      </a>
                    </li>
                    <li className="media-item">
                      <a href="#">
                        <img src={ require("temp/avater4.jpg") } className="avater-small" alt="凯文·史派西" />
                        <span className="txt">凯文·史派西</span>
                      </a>
                    </li>
                    <li className="media-item">
                      <a href="#">
                        <img src={ require("temp/avater5.jpg") } className="avater-small" alt="斯嘉丽·约翰逊" />
                        <span className="txt">斯嘉丽·约翰逊</span>
                      </a>
                    </li>
                    <li className="media-item">
                      <a href="#">
                        <img src={ require("temp/avater6.jpg") } className="avater-small" alt="周星驰" />
                        <span className="txt">周星驰</span>
                      </a>
                    </li>
                  </ul>
                  {/* 媒体人列表 E */}
                </div>
                <a href="#" className="btn btn-grey btn-big btn-line center-block">查看所有候选</a>
              </div>
            </div>
          </div>
          {/* 我的御用媒体 E */}
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
    );
  }
}