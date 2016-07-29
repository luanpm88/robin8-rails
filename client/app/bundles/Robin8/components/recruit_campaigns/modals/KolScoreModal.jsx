import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';

export default class KolScoreModal extends Component {
  close() {
    const onHide = this.props.onHide;
    onHide();
  }

  cancel() {
    this.close();
  }

  submit() {
    const { updateKolScoreAndBrandOpinion } = this.props.actions;
    const campaign_id = this.props.campaignInvite.get("campaign").get("id");
    const index = this.props.index;
    const kol_id = this.props.campaignInvite.get("kol").get("id");
    const score = '5';
    const opinion = "good"
    updateKolScoreAndBrandOpinion(campaign_id, kol_id, index, score, opinion);
    this.close();
  }

  render() {
    return (
      <Modal {...this.props} className="revoke-modal">
        <Modal.Header closeButton>
          <Modal.Title>我的评价</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className="kol-score-group">
            <span>打分</span>
            <span>XXXXXX</span>
          </div>
          <div className="brand-opinion-group">
            <p>写下你的意见</p>
            <textarea></textarea>
          </div>
          <button onClick={this.submit.bind(this)} className='btn btn-blue sure'>提交</button>
        </Modal.Body>
      </Modal>
    );
  }
}
