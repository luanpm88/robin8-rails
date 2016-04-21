import React, { PropTypes } from "react";
import { Link } from 'react-router';
import isSuperVistor from '../shared/VisitAsAdmin';

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

  // render_screenshot(){
  //   const { campaign_invite} = this.props;
  //   if(campaign_invite.get("img_status") == "passed"){
  //     return(<td><a href={campaign_invite.get("screenshot")} target="_blank"><img src={campaign_invite.get("screenshot")} className="kolCampaignScreenshot"></img></a></td>)
  //   }
  //   return(<td>未上传截图</td>)
  // }

  render(){
    const { campaign_invite } = this.props;
    return(
      <tr>
        {this.render_kol_id()}
        {this.render_avatar(campaign_invite)}
        <td>{campaign_invite.get("kol").get("name") || "该用户未设置昵称"}</td>
        <td>{campaign_invite.get("kol").get("fans_count")}</td>
        <td>{campaign_invite.get("kol").get("influence_score")}</td>
        <td>{campaign_invite.get("kol").get("city")}</td>
        <td>{campaign_invite.get("agree_reason")}</td>
      </tr>
    )
  }
}
