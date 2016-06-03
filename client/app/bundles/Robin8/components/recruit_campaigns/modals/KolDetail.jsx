import React, { Component } from 'react';
import { Modal, Button, Carousel, Glyphicon } from 'react-bootstrap';

export default class KolDetailModal extends Component {

  constructor(props, context){
    super(props, context);
    this.state = {
      prevIcon: <Glyphicon glyph="menu-left" />,
      nextIcon: <Glyphicon glyph="menu-right" />
    };
  }

  close() {
    const onHide = this.props.onHide;
    onHide();
  }

  render_avatar(){
    const campaign_invite = this.props.campaignInvite;

    if (campaign_invite.get("kol").get("avatar_url")){
      return(<img src={campaign_invite.get("kol").get("avatar_url")} className="blurUserAvatar"></img>)
    }
    return(<img src={require("default_pic.png")} className="blurUserAvatar"></img>)
  }


  render() {
    const campaign_invite = this.props.campaignInvite;
    return (
      <Modal {...this.props} className="kol-detail-modal" closeButton>
        <Modal.Header closeButton>
          <div className="avatar">
            {this.render_avatar()}
            <span className="brand-name">{campaign_invite.get('kol').get('name')}</span>
          </div>
          <ul className="list-inline info">
            <li className="weibo">
              <span className="weibo-count-text">微博粉丝量</span>
              <span className="weibo-count">{campaign_invite.get("weibo_friend_count") || "-"}</span>
            </li>
            <li className="wechat">
              <span className="wechat-count-text">微信粉丝量</span>
              <span className="wechat-count">{campaign_invite.get("weixin_friend_count") || "-"}</span>
            </li>
            <li className="score">
              <span className="score-text">影响力分数</span>
              <span className="score-number">{campaign_invite.get("kol").get("influence_score") || "-"}</span>
            </li>
            <li className="location">
              <span className="location-text">地区</span>
              <span className="location-city">{campaign_invite.get("kol").get("city") || "-"}</span>
            </li>
          </ul>
        </Modal.Header>
        <Modal.Body>
          <div className="recommand-detail">
            <p className='agree-reason'>推荐原因: {campaign_invite.get("agree_reason")}</p>
            <p className='remark'>用户备注: {campaign_invite.get("remark")}</p>
            <Carousel prevIcon={this.state.prevIcon} nextIcon={this.state.nextIcon}>
              { do
                {
                  campaign_invite.get("images").toArray().map(function(img, index){
                    return (
                      <Carousel.Item key={index}>
                        <img className="screenshot-img" alt="211x375" src={img}/>
                      </Carousel.Item>
                    )
                  })
                }
              }
            </Carousel>
          </div>
        </Modal.Body>
      </Modal>
    );
  }
}
