import React, { PropTypes } from "react";
import { Link } from 'react-router';
import isSuperVistor from '../../shared/VisitAsAdmin';

export default class InviteKol extends React.Component {
  constructor(props, context){
    super(props, context);
  }

  render_kol_id() {
    const { campaign_invite } = this.props;
    if (isSuperVistor()) {
      return <td>{campaign_invite.get("kol").get("id")}</td>
    }
  }

  render_avatar(campaign_invite){
    if (campaign_invite.get("kol").get("avatar_url")){
      return(<td><img src={campaign_invite.get("kol").get("avatar_url")} className="blurUserAvatar"></img></td>)
    }
    return(<td><img src={require("default_pic.png")} className="blurUserAvatar"></img></td>)
  }

  render_avail_click(){
    const { campaign_invite, campaign } = this.props;
    if(campaign.get("per_budget_type") == "cpa" || campaign.get("per_budget_type") == "click"){
      return <td>{campaign_invite.get("get_avail_click")}</td>
    }
  }

  render_total_click(){
    const { campaign_invite, campaign } = this.props;
    if(campaign.get("per_budget_type") != "simple_cpi" || campaign.get("per_budget_type") != "cpt" || campaign.get("per_budget_type") != "recruit"){
      return <td>{campaign_invite.get("get_total_click")}</td>
    }
  }

  render_reward(){
    const { campaign_invite, campaign} = this.props;
    if(campaign.get("per_budget_type") == "cpa" || campaign.get("per_budget_type") == "click"){
      if (Number.isSafeInteger(campaign.get("per_action_budget")) === true || campaign_invite.get("get_avail_click") == 0){
        return(<td>{(campaign_invite.get("get_avail_click")*campaign.get("per_action_budget")).toFixed()}</td>)
      }else{
        return(<td>{(campaign_invite.get("get_avail_click")*campaign.get("per_action_budget")).toFixed(1)}</td>)
      }
    }
    return(<td>{campaign.get("per_action_budget")}</td>)
  }

  render_screenshot(){
    const { campaign_invite} = this.props;
    let screenshot_arr = !!campaign_invite.get("screenshot")._root ? campaign_invite.get("screenshot") : '';
    const screenshots = screenshot_arr.split(",");
    const renderScreenshots = screenshots.map(function(screenshot) {
      return (
        <a href={screenshot} target="_blank">
          <img src={screenshot} className="kolCampaignScreenshot"/>
        </a>
      )
    })
    if(campaign_invite.get("img_status") == "passed"){
      return(
        <td style={{width: '300px'}}>
          {renderScreenshots}
          {/* <a href={campaign_invite.get("screenshot")} target="_blank">
          <img src={campaign_invite.get("screenshot")}
            className="kolCampaignScreenshot"></img>
          </a> */}
        </td>
          )
    }
    return(<td>未上传截图</td>)
  }

  render(){
    const { campaign_invite } = this.props;
    return(
      <tr>
        {this.render_kol_id()}
        {this.render_avatar(campaign_invite)}
        <td>{campaign_invite.get("kol").get("name") || "该用户未设置昵称"}</td>
        {this.render_avail_click()}
        {this.render_total_click()}
        {this.render_reward()}
        {this.render_screenshot()}
      </tr>
    )
  }
}
