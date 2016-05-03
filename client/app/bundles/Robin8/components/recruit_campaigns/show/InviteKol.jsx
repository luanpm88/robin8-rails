import React, { PropTypes } from "react";
import { Link } from "react-router";
import isSuperVistor from "../../shared/VisitAsAdmin";
import SwitchBox from "../../shared/SwitchBox";

export default class InviteKol extends React.Component {
  constructor(props, context){
    super(props, context);
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

  render(){
    const { campaign_invite } = this.props;

    return(
      <tr>
        {this.render_kol_id()}
        {this.render_profile(campaign_invite)}
        <td>
          {campaign_invite.get("weibo_friend_count") || "-"}
          <i className="slash">/</i>
          {campaign_invite.get("weixin_friend_count") || "-"}
        </td>
        <td>{campaign_invite.get("kol").get("influence_score") || "-"}</td>
        <td>{campaign_invite.get("kol").get("city") || "-"}</td>
        <td>{campaign_invite.get("agree_reason") || "-"}</td>
        {this.render_screenshot_or_switchbox()}
      </tr>
    )
  }
}
