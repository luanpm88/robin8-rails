import React, { Component } from 'react';
import { Link } from 'react-router';
import moment from 'moment';
import { connect } from 'react-redux';

import "brand_activity_detail.css";

import Basic from './campaign_show/Basic';
import Overview from './campaign_show/Overview';
import Target from './campaign_show/Target';
import KolList from './campaign_show/KolList';

function select(state){
  return { 
    campaign_invites: state.$$brandStore.get("campaign_invites"),
    hasfetchedInvite: state.$$brandStore.get("hasfetchedInvite"),
    paginate: state.$$brandStore.get("paginate"),
  };
}
export default class ShowCampaignPartial extends Component {
  componentDidMount() {
    this.set_campaign();
    this.bind_toggle_text();
  }

  set_campaign() {
    const campaign_id = this.props.params.id;
    const { fetchCampaign } = this.props.actions;

    // can load campaign from campaigns
    // const campaigns = this.props.data.get("campaigns");

    fetchCampaign(campaign_id);
  }

  bind_toggle_text() {
    $('.panel').each(function(){
      $(this).on('shown.bs.collapse', function () {
        $(this).find('.switch .txt').text('收起');
      });
      $(this).on('hidden.bs.collapse', function () {
        $(this).find('.switch .txt').text('展开');
      });
    });
  }

  render_breadcrumb() {
    return (
      <ol className="breadcrumb">
        <li>
          <i className="caret-arrow left" />
          <Link to="/brand/">我的主页</Link>
        </li>
      </ol>
    );
  }

  render_influence(campaign) {
    return (
      <div className="panel influence-charts-panel">
        <div className="panel-heading">
          <a href="#influenceChartsPanel" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
          <h4 className="panel-title">影响力</h4>
        </div>
        <div id="influenceChartsPanel" className="panel-collapse collapse in">
          <div className="panel-body">
            <div className="influence-charts-area">
              <div className="header clearfix">
                {/* 类别视图菜单 */}
                <div className="charts-legend pull-left">
                  <button className="btn active">总览</button>
                  <span className="space">/</span>
                  <button className="btn">自媒体视图</button>
                  <span className="space">/</span>
                  <button className="btn">社交平台视图</button>
                </div>
                {/* 日期视图菜单 */}
                <div className="charts-legend pull-right">
                  <button className="btn active">月视图</button>
                  <span className="space">/</span>
                  <button className="btn">周视图</button>
                  <span className="space">/</span>
                  <button className="btn">天视图</button>
                </div>
              </div>
              {/* 图表显示区域 S */}
              <div className="content">
                <div className="charts-box">图表高度240px</div>
                {/* 颜色提示 */}
                <div className="charts-color-indicator">
                  <span className="color-label cpc"><i />CPC开放招募</span>
                  <span className="color-label tweeted"><i />转发型自媒体</span>
                  <span className="color-label original"><i />创作型自媒体</span>
                </div>
                {/* 当天数据 */}
                <div className="infographic-tody-box">
                  <h5 className="tit">2016.01.31 当天数据</h5>
                  <span className="stat">总点击量<strong className="stat-num">123456789</strong></span>
                  <div className="infographic-show">
                    <div className="inf-show original" style={{width: '20%'}}><strong className="stat-num">65</strong></div>
                    <div className="inf-show tweeted" style={{width: '30%'}}><strong className="stat-num">45</strong></div>
                    <div className="inf-show cpc" style={{width: '10%'}}><strong className="stat-num">124</strong></div>
                  </div>
                </div>
              </div>
              {/* 图表显示区域 E */}
              <div className="footer">
                <a href="#" className="btn btn-grey btn-big btn-line center-block">查看详细</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  render() {
    const campaign = this.props.data.get('campaign');
    const { actions, campaign_invites, hasfetchedInvite, paginate} = this.props;
    const campaign_id = this.props.params.id
    return (
      <div className="wrapper">
        <div className="container">
          { this.render_breadcrumb(campaign) }
          <Basic {...{campaign}} />
          <Overview {...{campaign}} />
          <Target {...{campaign}} />
          <KolList {...{campaign, actions, campaign_invites, campaign_id, hasfetchedInvite, paginate}} />
          { this.render_influence(campaign) }
        </div>
      </div>
    );
  }
}

export default connect(select)(ShowCampaignPartial)