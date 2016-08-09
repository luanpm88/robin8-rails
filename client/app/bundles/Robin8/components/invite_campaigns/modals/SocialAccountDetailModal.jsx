import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';

const baseUrl = "/brand_api/v1"

export default class SocialAccountDetailModal extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
      socialAccount: null
    };
  }

  close() {
    const onHide = this.props.onHide;
    onHide();
  }

  loadSocialAccount() {
    const id = this.props.socialAccountId;
    const { socialAccount } = this.state;

    if (!socialAccount || socialAccount.id != id) {
      fetch(`${baseUrl}/social_accounts/${id}`, { credentials: 'same-origin' })
        .then(response => response.json())
        .then(data => {
          this.setState({socialAccount: data});
        })
        .catch(e => {
          console.log("[ERROR]", e)
        })
    }
  }

  cancel() {
    this.close();
  }

  renderProfile() {
    const socialAccount = this.state.socialAccount;
    let tagList = [], locationElement = null;

    tagList = socialAccount.tags.map(tag => {
      return <em>{tag.label}</em>;
    });

    if (!!socialAccount.province || !!socialAccount.city) {
      locationElement = <span className="location">
        {socialAccount.province} {socialAccount.city}
      </span>
    }

    return (
      <div className="profile-wrap">
        <div className="avatar">
          <img src={socialAccount.avatar_url} />
        </div>
        <div className="info">
          <h4>{socialAccount.username}</h4>
          <div className="baseinfo">
            <span className="gender">{socialAccount.gender ? "男" : "女"}</span>/
            <span className="provider">
              <a href={socialAccount.homepage} target="_blank">
                {socialAccount.provider_text}
              </a>
            </span>/
            {locationElement || " 未知"}
          </div>
          <div className="brief">
            {socialAccount.brief}
          </div>
          <hr />
          <div className="statistic">
            <ul>
              <li className="sale_price">价格 {socialAccount.sale_price}元/条</li>
              <li className="tags">分类 {tagList.length > 0 ? tagList : "未知"}</li>
              <li>点赞数 {socialAccount.like_count      || "未知"}</li>
              <li>粉丝数 {socialAccount.followers_count || "未知"}</li>
              <li>关注数 {socialAccount.friends_count   || "未知"}</li>
              <li>转发数 {socialAccount.reposts_count   || "未知"}</li>
              <li>文章数 {socialAccount.statuses_count  || "未知"}</li>
            </ul>
          </div>
        </div>
      </div>
    );
  }

  render() {
    const socialAccount = this.state.socialAccount;
    let profileElement;

    if (!!socialAccount) {
      profileElement = this.renderProfile();
    }

    return (
      <Modal {...this.props}
        onEnter={this.loadSocialAccount.bind(this)}
        bsSize="sm"
        className="social-account-detail-modal">
        <Modal.Body>
          {profileElement}
          <div className="close">
            <span onClick={this.cancel.bind(this)}
                    className='cancel'>关闭</span>
          </div>
        </Modal.Body>
      </Modal>
    );
  }
}
