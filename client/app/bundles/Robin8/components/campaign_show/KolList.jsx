import React, { PropTypes } from "react";
import { Link } from 'react-router';

import InviteKol from './InviteKol'
export default class KolList extends React.Component {
  constructor(props, context){
    super(props, context);
  }

  componentDidMount(){
    const { fetchInvitesOfCampaign } = this.props.actions;
    if(this.props.campaign_id){
      fetchInvitesOfCampaign(this.props.campaign_id, {page: 1})
    }
  }

  componentDidUpdate() {
    this.displayPaginator()
  }

  displayPaginator() {
    const that =  this
    const { fetchInvitesOfCampaign } = this.props.actions;
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
          fetchInvitesOfCampaign(campaign_id,  {page: page});
        }
      }
      $("#campaign_invites-paginator").bootstrapPaginator(pagination_options);
    }
  }

  render_kol_list_header(){
    const campaign = this.props.campaign
    const campaign_invites = this.props.campaign_invites
    if(campaign_invites.size == 0){
      return
    }
    if(campaign.get("per_budget_type") != "post"){
      return(<tr><td>头像</td><td>昵称</td><td>计费点击</td><td>总点击</td><td>奖励</td><td>截图</td></tr>)
    }
    return(<tr><td>头像</td><td>昵称</td><td>总点击</td><td>奖励</td><td>截图</td></tr>)
  }

  render_kol_list(){
    const campaign_invites = this.props.campaign_invites
    const campaign = this.props.campaign
    const hasfetchedInvite = this.props.hasfetchedInvite
    if(hasfetchedInvite && (campaign_invites.size > 0)){
      return(
        <div id="panelKolsBigShow" className="panel-collapse collapse in">
          <div className="panel-body">
            <table className="table table-hover panelKolsTable">
              <thead>
                {this.render_kol_list_header()}
              </thead>
              <tbody>
                { do
                  {
                    campaign_invites.map(function(invite, index){
                      return <InviteKol campaign_invite={invite} key={index} campaign={campaign}/>
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
      showTip = "暂时还没有kol, 转发活动!"
    }
    return(
      <div className="panel-body showMiddleTip">
        {showTip}
      </div>
    )
  }

  render(){

    return(
      <div className="panel ">
        <div className="panel-heading">
          <a href="#panelKolsBigShow" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
          <h4 className="panel-title">KOL列表</h4>
            {this.render_kol_list()}
        </div>
      </div>
    )
  }
}