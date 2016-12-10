import React, { PropTypes } from "react";
import { Link } from 'react-router';

import isSuperVistor from '../../shared/VisitAsAdmin';

export default class Evaluation extends React.Component {
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


  render_kol_list(){
    const campaign = this.props.campaign
    if(campaign.get("evaluation_status") == 'evaluated'){
      return(
        <div className="panel-body">
          <div className="evaluation-items">
            <div className="item">
              <div className="name">效果评分:</div>
              <div className="value">{campaign.get("effect_score")} 分</div>
            </div>
            <div className="item">
              <div className="name">评价内容:</div>
              <div className="value">{campaign.get("review_content")}</div>
            </div>
          </div>
        </div>
      )
    }
    if(campaign.get("evaluation_status") == 'pending'){
      return(
        <div className="panel-body showMiddleTip">
          活动还未结算,暂时不能评价活动!
        </div>
      )
    }else if (campaign.get("evaluation_status") == 'evaluating'){
      return(
        <div className="panel-body showMiddleTip">
          活动已结算,速速去评价! <Link to={`/brand/campaigns/${campaign.get("id")}/evaluate`} className="before-pay-edit-campaign-btn">评价</Link>
        </div>
      )
    }else{
      return(
        <div className="panel-body showMiddleTip">
          数据加载中..
        </div>
      )
    }
  }

  render(){
    return(
      <div className="panel ">
        <div className="panel-heading">
          <a href="#panelEvaluationShow" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
          <h4 className="panel-title">评价详情</h4>
          <div id="panelEvaluationShow" className="panel-collapse collapse in">
            {this.render_kol_list()}
          </div>
        </div>
      </div>
    )
  }
}
