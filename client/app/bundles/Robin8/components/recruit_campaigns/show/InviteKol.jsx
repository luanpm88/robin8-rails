import React, { PropTypes } from "react";
import { Link } from "react-router";
import KolDetailModal from '../modals/KolDetailModal';
import KolScoreModal  from '../modals/KolScoreModal';
import KolScoreInfoModal from '../modals/KolScoreInfoModal';

import isSuperVistor from "../../shared/VisitAsAdmin";
import SwitchBox from "../../shared/SwitchBox";

export default class InviteKol extends React.Component {
  constructor(props, context){
    super(props, context);
    this.state = {
      showKolDetailModal: false,
      showKolScoreModal: false,
      showKolScoreInfoModal: false
    };
  }

  closeShowKolDetailModal() {
    this.setState({showKolDetailModal: false});
  }

  closeShowKolScoreModal() {
    this.setState({showKolScoreModal: false});
  }

  closeShowKolScoreInfoModal() {
    this.setState({showKolScoreInfoModal: false});
  }

  updateKolStatus(status) {
    const { campaign, campaign_id, campaign_invite, actions } = this.props;
    const kod_id = campaign_invite.get("kol").get("id");

    actions.updateRecruitCompaignKolStatus(campaign_id, kod_id, this.props.index, status);
  }

  render_kol_id() {
    const { campaign_invite } = this.props;
    if (isSuperVistor()) {
      return <td>{campaign_invite.get("kol").get("id")}</td>
    }
  }

  render_profile(campaign_invite){
    let img_url = campaign_invite.get("kol").get("avatar_url") || require("default_pic.png");
    return (
      <td className="profile">
        <img src={ img_url } className="avatar"></img>
        <span className="name">{ campaign_invite.get("name") || "该用户未设置昵称" }</span>
      </td>
    )
  }

  render_screenshot_or_switchbox() {
    const { campaign, campaign_id, campaign_invite, actions } = this.props;
    const status = campaign.get("recruit_status");

    if (status === "choosing") {
      return (
        <td>
          <SwitchBox
            onUserClick={this.updateKolStatus.bind(this)}
            activeValue={campaign_invite.get("status") === "brand_passed"}
          />
        </td>
      );
    } else if (status === "settling" || status === "settled") {
      if(campaign_invite.get("img_status") == "passed"){
        return (
          <td>
            <a href={campaign_invite.get("screenshot")} target="_blank">
              <img src={campaign_invite.get("screenshot")} className="kolCampaignScreenshot"/>
            </a>
          </td>
        )
      }
      return (
        <td className="grey">未上传</td>
      )
    } else if (status === "running") {
      const passed = campaign_invite.get("status") === "brand_passed";

      return (
        <td className={ passed ? "" : "grey" } >{ !!passed ? "已招募" : "未招募" }</td>
      );
    }
  }

  show_kol_detail_modal() {
    this.setState({showKolDetailModal: true})
  }

  show_kol_score_modal() {
    this.setState({showKolScoreModal: true})
  }

  show_score_info_modal() {
    this.setState({showKolScoreInfoModal: true})
  }

  render_remark_and_pictures() {
    const { campaign_invite } = this.props;
    return (
      <td className="detail-info"><a onClick={this.show_kol_detail_modal.bind(this)}>详细信息</a></td>
    )
  }

  renderScoreMarkButton() {
    const { campaign, campaign_invite } = this.props;
    const status = campaign.get("recruit_status");
    if (status === "settling" || status === "settled") {
      if (campaign_invite.get("kol_score")) {
        return <td><button className="btn btn-blue btn-default show-score-mark-btn" onClick={this.show_score_info_modal.bind(this)}>查看评分</button></td>
      }
      return <td><button className="btn btn-blue btn-default score-mark-btn" onClick={this.show_kol_score_modal.bind(this)}>评分</button></td>
    }
  }

  render(){
    const { campaign_invite } = this.props;

    return(
      <tr>
        {this.render_kol_id()}
        {this.render_profile(campaign_invite)}
        {/* <td>campaign_invite.get("weixin_friend_count") || "-"</td> */}
        <td>{campaign_invite.get("kol").get("city") || "-"}</td>
        {/* <td>{campaign_invite.get("get_avail_click") || "-"}</td> */}
        {this.render_remark_and_pictures()}
        {this.render_screenshot_or_switchbox()}
        {this.renderScoreMarkButton()}
        <KolDetailModal show={this.state.showKolDetailModal} onHide={this.closeShowKolDetailModal.bind(this)} actions={this.props.actions} campaignInvite={campaign_invite} />
        <KolScoreModal show={this.state.showKolScoreModal} onHide={this.closeShowKolScoreModal.bind(this)} index={this.props.index} isRecuritCampaign={true} actions={this.props.actions} campaignInvite={campaign_invite} />
        <KolScoreInfoModal show={this.state.showKolScoreInfoModal} onHide={this.closeShowKolScoreInfoModal.bind(this)} campaignInvite={campaign_invite}  />
      </tr>
    )
  }
}
