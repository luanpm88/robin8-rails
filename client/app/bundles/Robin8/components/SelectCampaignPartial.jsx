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
                <h3>悬赏活动</h3>
              </div>
              <div className="at-box-ct">
                <p className="bold">支持朋友圈文章类广告发布</p>
                <p>KOL分享文章到朋友圈后，</p>
                <p>[CPC]按照好友有效点击数付费</p>
                <p>[CPP]按照KOL转发一次性付费</p>
                <p>[CPT]按照KOL完成任务一次性付费</p>
              </div>
              <div className="at-box-bt at-box-bt-left">
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
                <p className="bold">支持主流社交平台自定义广告发布</p>
                <p>广告主创建活动，KOL报名，广告主会挑选</p>
                <p>合适的KOL接单，按照KOL完成活动</p>
                <p>一次性付费，广告主定价</p>
              </div>
              <div className="at-box-bt">
                <Link to="/brand/recruits/new" className="btn">
                  立即创建
                </Link>
              </div>
            </div>

            {

              <div className="at-s-box hide">
                <div className="at-box-mk mk-new">
                  <div className="mk-bg"></div>
                  <i>NEW</i>
                </div>
                <div className="at-box-hd">
                  <div className="at-box-pic">
                    <img src={require('icon-gift.png')} />
                  </div>
                  <h3>特邀活动</h3>
                </div>
                <div className="at-box-ct">
                  <p className="bold">支持主流社交平台自定义广告发布</p>
                  <p>广告主创建活动，邀请特定的KOL接单，</p>
                  <p>按照KOL完成活动一次性付费，</p>
                  <p>广告主需接受KOL的报价</p>
                </div>
                <div className="at-box-bt">
                  <Link to="/brand/invites/new" className="btn">
                    立即创建
                  </Link>
                </div>
              </div>
            }


          </div>
          <div className="at-s-bottom">
            <a href="/contact" target="_blank" className="btn service-call">
              有问题请联系客服
            </a>
          </div>
        </div>
      </div>
    );
  }
}

export default SelectCampaignPartial;
