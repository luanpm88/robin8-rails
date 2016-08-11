import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';
import StarRating from 'react-star-rating';
import "react-star-rating/dist/css/react-star-rating.min.css";

export default class KolScoreInfoModal extends Component {

  constructor(props, context) {
    super(props, context);
  }


  close() {
    const onHide = this.props.onHide;
    onHide();
  }


  cancel() {
    this.close();
  }

  renderOpinion() {
    const campaign_invite = this.props.campaignInvite;
    if(campaign_invite.get("brand_opinion")) {
      return (
        <div className="brand-opinion-group">
          <p className="my-opinion">我的意见</p>
          <p>{campaign_invite.get("brand_opinion")}</p>
        </div>
      )
    }
  }

  render() {
    const campaign_invite = this.props.campaignInvite;
    return (
      <Modal {...this.props} className="kol-score-modal">
        <Modal.Header closeButton>
          <Modal.Title>我的评价</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className="kol-score-group">
            <span className="give-score">评分</span>
            <StarRating name="star-rating" size={30} totalStars={5} rating={parseInt(campaign_invite.get("kol_score"))} />
          </div>
          {this.renderOpinion()}
        </Modal.Body>
      </Modal>
    );
  }
}
