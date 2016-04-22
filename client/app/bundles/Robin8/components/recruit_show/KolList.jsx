import React, { PropTypes } from "react";
import { Link } from 'react-router';

import InviteKol from './InviteKol'
import isSuperVistor from '../shared/VisitAsAdmin';

export default class KolList extends React.Component {
  constructor(props, context){
    super(props, context);
  }

  componentDidMount(){
    const { fetchAppliesOfRecruit } = this.props.actions;
    if(this.props.campaign_id){
      fetchAppliesOfRecruit(this.props.campaign_id, {page: 1})
    }
  }

  componentDidUpdate() {
    this.displayPaginator()
  }

  displayPaginator() {
    const that =  this
    const { fetchAppliesOfRecruit } = this.props.actions;
    const { campaign_id } = this.props
    if (this.props.paginate.get("X-Page")) {
      const pagination_options = {
        currentPage: this.props.paginate.get("X-Page"),
        totalPages: this.props.paginate.get("X-Total-Pages"),
        shouldShowPage: function(type, page, current) {
          switch (type) {
            default:
              return true
          }
        },
        onPageClicked:  function(e,originalEvent,type,page){
          fetchAppliesOfRecruit(campaign_id,  {page: page});
        }
      }
      $("#campaign_invites-paginator").bootstrapPaginator(pagination_options);
    }
  }

  updateKols() {
    const { updateRecruitCompaignKols } = this.props.actions;
    const { campaign_id } = this.props;

    updateRecruitCompaignKols(campaign_id);
  }

  render_super_vistor_header() {
    if (isSuperVistor()) {
      return (
        <th>kol id</th>
      )
    }
  }

  render_status_header() {
    if (this.props.status === "choosing" ||
      this.props.status === "running") {
      return (
        <th>状态</th>
      )
    } else if (this.props.status === "finished") {
      return (
        <th>截图</th>
      )
    }
  }

  render_kol_list_header(){
    const campaign_invites = this.props.campaign_invites
    const campaign = this.props.campaign

    if(campaign_invites.size == 0){
      return
    }

    return(
      <tr>
        { this.render_super_vistor_header() }
        <th><h4>报名列表</h4></th>
        <th>微博/微信粉丝量</th>
        <th>影响力分数</th>
        <th>地区</th>
        <th>推荐原因</th>
        { this.render_status_header() }
      </tr>
    )
  }

  render_kol_list(){
    const { campaign, campaign_id, status, campaign_invites, actions } = this.props;
    const hasfetchedInvite = this.props.hasfetchedInvite;

    if(hasfetchedInvite && (campaign_invites.size > 0)){
      return(
        <div id="panelKolsBigShow" className="kols-list-wrapper">
          <div className="panel-body">
            <table className="table table-hover panelKolsTable">
              <thead>
                {this.render_kol_list_header()}
              </thead>
              <tbody>
                { do
                  {
                    campaign_invites.map(function(invite, index){
                      return <InviteKol
                        campaign_invite={invite}
                        key={index}
                        campaign_id={campaign_id}
                        campaign={campaign}
                        status={status}
                        actions={actions}
                      />
                    })
                  }
                }
              </tbody>
            </table>
            <div id="campaign_invites-paginator"></div>
          </div>
        </div>
      )
    }
    let showTip = "正在加载中..."
    if(hasfetchedInvite && campaign_invites.size == 0){
      showTip = "暂时还没有人报名"
    }
    return(
      <div className="panel-body showMiddleTip">
        {showTip}
      </div>
    )
  }

  render_bottom_tips() {
    if (this.props.status != "inviting") { return; }

    return (
      <div className="bottom-tips">*请在报名截止后确定招募名单</div>
    );
  }

  render_kol_stat() {
    const { campaign, status } = this.props;

    if (status != "choosing") { return; }

    return (
      <div className="kol-stat-wrapper">
        <div className="kol-stat-container">
          <div className="stat-overview">
            <ul>
              <li>
                <h5>已选中</h5>
                <span className="bold">{ campaign.get("brand_passed_count") }</span>
              </li>
              <li>
                <h5>招募</h5>
                <span className="bold">{ campaign.get("valid_applies_count") }</span>
              </li>
            </ul>
          </div>
          <div className="kol-form">
            <button className="btn btn-primary kol-submit" onClick={this.updateKols.bind(this)}>提交名单</button>
          </div>
        </div>
      </div>
    );
  }

  render(){
    return(
      <div>
        <div className="panel">
          <div className="panel-heading">
            {this.render_kol_list()}
          </div>
        </div>
        { this.render_bottom_tips() }
        { this.render_kol_stat() }
      </div>
    )
  }
}
