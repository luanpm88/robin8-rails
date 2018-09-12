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

  render_screenshots() {
    const campaign_invite = this.props.campaignInvite;
    if (!!campaign_invite.get("images") && campaign_invite.get("images").size) {
      return <Carousel prevIcon={this.state.prevIcon} nextIcon={this.state.nextIcon}>
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
    }
  }

  render() {
    const campaign_invite = this.props.campaignInvite;
    return (
      <Modal {...this.props} className="kol-detail-modal" closeButton>
        <Modal.Header closeButton>
          <div className="avatar">
            { this.render_avatar() }
            <span className="brand-name">{campaign_invite.get('kol').get('name')}</span>
          </div>
          <ul className="list-inline info">
            <li className="weibo">
              <div className="weibo-count-text">
                <a href={campaign_invite.get("weibo_homepage")} target="_blank"><Glyphicon glyph="link" /> 微博粉丝量</a>
              </div>
              <div className="weibo-count">{campaign_invite.get("weibo_friend_count") || "-"}</div>
            </li>
            <li className="wechat">
              <div className="wechat-count-text">微信粉丝量</div>
              <div className="wechat-count">{campaign_invite.get("weixin_friend_count") || "-"}</div>
            </li>
            <li className="location">
              <div className="location-text">地区</div>
              <div className="location-city">{campaign_invite.get("kol").get("city") || "-"}</div>
            </li>
          </ul>
        </Modal.Header>
        <Modal.Body>
          <div className="recommand-detail">
            <p className='agree-reason'>推荐原因: {campaign_invite.get("agree_reason")}</p>
            <p className='remark'>用户备注: {campaign_invite.get("remark") || "无备注" }</p>
            { this.render_screenshots() }
          </div>
        </Modal.Body>
      </Modal>
    );
  }
}
