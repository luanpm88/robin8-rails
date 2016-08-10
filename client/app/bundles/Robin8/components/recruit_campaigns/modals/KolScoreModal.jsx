import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';
import validator from 'validator';
import StarRating from 'react-star-rating';
import "react-star-rating/dist/css/react-star-rating.min.css";

export default class KolScoreModal extends Component {

  constructor(props, context) {
    super(props, context);
    this.state = { kol_score: '' }
  }


  close() {
    const onHide = this.props.onHide;
    onHide();
  }


  cancel() {
    this.close();
  }

  handleRatingClick(e, data) {
    this.setState({kol_score: data.rating});
    $(".kol-score-error-tip").hide();
  }

  submit() {
    const { updateKolScoreAndBrandOpinionOfRecruit,  updateKolScoreAndBrandOpinionOfInvite} = this.props.actions;
    const index = this.props.index;
    const campaign_id = this.props.campaignInvite.get("campaign").get("id");
    const kol_id = this.props.campaignInvite.get("kol").get("id");
    const score = this.state.kol_score;
    const opinion = this.refs.opinion_textarea.value;
    if(!score) {
      $(".kol-score-error-tip").show();
      return;
    }

    if(opinion) {
      if(!(validator.isLength(opinion, {min: 1, max: 50}))) {
        $(".brand-opinion-error-tip").show();
        return ;
      }
    }

    if(this.props.isRecuritCampaign) {
      updateKolScoreAndBrandOpinionOfRecruit(campaign_id, kol_id, index, score, opinion);
    } else if(this.props.isInviteCampaign) {
      updateKolScoreAndBrandOpinionOfInvite(campaign_id, kol_id, index, score, opinion);
    }

    this.close();
  }

  render() {
    return (
      <Modal {...this.props} className="kol-score-modal">
        <Modal.Header closeButton>
          <Modal.Title>我的评价</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className="kol-score-group">
            <span className="give-score">打分</span>
            <StarRating name="star-rating" size={30} totalStars={5} onRatingClick={this.handleRatingClick.bind(this)} />
          </div>
          <p className="kol-score-error-tip" style={{display: 'none'}}>请选择分数</p>
          <div className="brand-opinion-group">
            <p className="my-opinion">写下你的意见</p>
            <textarea ref="opinion_textarea" placeholder="不超过50个字(选填)"></textarea>
          </div>
          <p className="brand-opinion-error-tip" style={{display: 'none'}}>不能超过50个字</p>
          <button onClick={this.submit.bind(this)} className="btn btn-blue btn-default btn-submit">提交</button>
        </Modal.Body>
      </Modal>
    );
  }
}
