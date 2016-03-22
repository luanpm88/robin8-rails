import React, { Component } from 'react';
import { Link } from 'react-router';
import moment from 'moment';
import "brand_activity_detail.css";

export default class ShowActivityPartial extends Component {
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

  render_basic_info(campaign) {
    return (
      <div className="brand-activity-card brand-activity-card-detail">
        <div className="brand-activity-content">
          <a href="#" className="btn btn-default btn-red btn-line stop-btn">停止</a>
          <h2 className="activity-title">{ campaign.get("name") }</h2>
          <small className="date">{ moment(campaign.get("created_at")).format('D.M.YYYY') }</small>
          <div className="summary">{ campaign.get("desc") }</div>
          <a href="#" className="link">{ campaign.get("url") }</a>
          <ul className="stat-info grid-3">
            <li><span className="txt">时间</span><strong className="stat-num">{ moment(campaign.get("created_at")).format('YYYY.M.D') }-{ moment(campaign.get("deadline ")).format('YYYY.M.D') }</strong></li>
            <li><span className="txt">保证金</span><strong className="stat-num"><sapn className="symbol">$</sapn>{ campaign.get("per_budget_type") }</strong></li>
            <li><span className="txt">一次点击</span><strong className="stat-num"><sapn className="symbol">$</sapn>{ campaign.get("per_budget_type") }</strong></li>
          </ul>
        </div>
        <div className="brand-activity-coverphoto pull-left">
          <img src={ campaign.get("url") } alt={ campaign.get("name") } />
        </div>
      </div>
    );
  }

  render_overview(campaign) {
    return (
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
    );
  }

  render_medias(campaign) {
    return (
      <div className="panel medias-all-panel">
        <div className="panel-heading">
          <a href="#panelMediasAll" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
          <a href="#" className="btn btn-blue btn-big quick-btn">添加新的媒体</a>
          <h4 className="panel-title">所有媒体<i className="carte">/</i><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>&nbsp;人</h4>
        </div>
        <div id="panelMediasAll" className="panel-collapse collapse in">
          <div className="panel-body">
            <table>
              <tbody>
                <tr>
                  <td>
                    {/* 一类媒体 S */}
                    <div className="media-class-infographic-card">
                      <div className="header">
                        <h6 className="tit">创作型媒体<br /><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</h6>
                      </div>
                      <div className="content">
                        {/* 条状图表 S */}
                        <div className="media-infographic-box">
                          <div className="infographic-show">
                            <div className="inf-show refuse" style={{width: '20%'}} />
                            <div className="inf-show check" style={{width: '30%'}} />
                            <div className="inf-show accept" style={{width: '10%'}} />
                            <div className="inf-show complete" style={{width: '40%'}} />
                          </div>
                          <ul className="stat-num-list">
                            <li><i className="state-color refuse" />拒绝<span className="rg"><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</span></li>
                            <li><i className="state-color check" />查看<span className="rg"><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</span></li>
                            <li><i className="state-color accept" />接受<span className="rg"><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</span></li>
                            <li><i className="state-color complete" />完成<span className="rg"><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</span></li>
                          </ul>
                        </div>
                        {/* 条状图表 E */}
                      </div>
                      <div className="footer"><a href="#" className="btn btn-grey btn-big btn-line center-block">查看详细</a></div>
                    </div>
                    {/* 一类媒体 E */}
                  </td>
                  <td>
                    {/* 一类媒体 S */}
                    <div className="media-class-infographic-card">
                      <div className="header">
                        <h6 className="tit">转发型自媒体<br /><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</h6>
                      </div>
                      <div className="content">
                        {/* 条状图表 S */}
                        <div className="media-infographic-box">
                          <div className="infographic-show">
                            <div className="inf-show check" style={{width: '30%'}} />
                            <div className="inf-show complete" style={{width: '70%'}} />
                          </div>
                          <ul className="stat-num-list">
                            <li><i className="state-color check" />查看<span className="rg"><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</span></li>
                            <li><i className="state-color complete" />完成<span className="rg"><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</span></li>
                          </ul>
                        </div>
                        {/* 条状图表 E */}
                      </div>
                      <div className="footer"><a href="#" className="btn btn-grey btn-big btn-line center-block">查看详细</a></div>
                    </div>
                    {/* 一类媒体 E */}
                  </td>
                  <td>
                    {/* 一类媒体 S */}
                    <div className="media-class-infographic-card">
                      <div className="header">
                        <h6 className="tit">CPC开放招募<br /><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</h6>
                      </div>
                      <div className="content">
                        {/* 条状图表 S */}
                        <div className="media-infographic-box">
                          <div className="infographic-show">
                            <div className="inf-show refuse" style={{width: '45%'}} />
                            <div className="inf-show check" style={{width: '5%'}} />
                            <div className="inf-show accept" style={{width: '50%'}} />
                          </div>
                          <ul className="stat-num-list">
                            <li><i className="state-color refuse" />拒绝<span className="rg"><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</span></li>
                            <li><i className="state-color check" />查看<span className="rg"><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</span></li>
                            <li><i className="state-color accept" />接受<span className="rg"><strong className="stat-num">{ campaign.get("per_budget_type") }</strong>人</span></li>
                          </ul>
                        </div>
                        {/* 条状图表 E */}
                      </div>
                      <div className="footer"><a href="#" className="btn btn-grey btn-big btn-line center-block">查看详细</a></div>
                    </div>
                    {/* 一类媒体 E */}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
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
    return (
      <div className="wrapper">
        <div className="container">
          { this.render_breadcrumb(campaign) }
          { this.render_basic_info(campaign) }
          { this.render_overview(campaign) }
          { this.render_medias(campaign) }
          { this.render_influence(campaign) }
        </div>
      </div>
    );
  }
}