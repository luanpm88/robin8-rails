import React, { PropTypes } from "react";
import { Link } from 'react-router';

export default class InviteKol extends React.Component {
  constructor(props, context){
    super(props, context);
  }

  render_avatar(campaign_invite){
    if (campaign_invite.get("kol").get("avatar_url")){
      return(<td><img src={campaign_invite.get("kol").get("avatar_url")} className="blurUserAvatar"></img></td>)
    }
    return(<td><img src={require("default_pic.png")} className="blurUserAvatar"></img></td>)
  }

  render_avail_click(){
    const { campaign_invite, campaign} = this.props;
    if(campaign.get("per_budget_type") == "cpa" || campaign.get("per_budget_type") == "click"){
      return <td>{campaign_invite.get("get_avail_click")}</td>
    }
  }

  render_reward(){
    const { campaign_invite, campaign} = this.props;
    if(campaign.get("per_budget_type") == "cpa" || campaign.get("per_budget_type") == "click"){
      return(<td>{campaign_invite.get("get_avail_click")*campaign.get("per_action_budget")}</td>)
    }
    return(<td>{campaign.get("per_action_budget")}</td>)
  }

  render_screenshot(){
    const { campaign_invite} = this.props;
    if(campaign_invite.get("img_status") == "passed"){
      return(<td><img src={campaign_invite.get("screenshot")} className="kolCampaignScreenshot"></img></td>)
    }
    return(<td>未上传截图</td>)
  }

  render(){
    const { campaign_invite} = this.props;
    return(
      <tr>
        {this.render_avatar(campaign_invite)}
        <td>{campaign_invite.get("kol").get("name") || "该用户未设置昵称"}</td>
        {this.render_avail_click()}
        <td>{campaign_invite.get("get_total_click")}</td>
        {this.render_reward()}
        {this.render_screenshot()}
      </tr>
    )
  }
}