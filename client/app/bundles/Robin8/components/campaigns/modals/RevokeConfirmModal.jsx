import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';

export default class RevokeConfirmModal extends Component {
  close() {
    const onHide = this.props.onHide;
    onHide();
  }

  cancel() {
    this.close();
  }

  revokeCampaign() {
    const { revokeCampaign } = this.props.actions;
    const campaign_id = this.props.campaignId;
    revokeCampaign(campaign_id);
    this.close();
  }

  render() {
    return (
      <Modal {...this.props} className="revoke-modal">
        <Modal.Header closeButton>
          <Modal.Title>确定要撤销此活动吗?</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className="btn-group">
            <button onClick={this.revokeCampaign.bind(this)} className='btn btn-blue sure'>确定</button>
            <button onClick={this.cancel.bind(this)} className='btn btn-red cancel'>取消</button>
          </div>
        </Modal.Body>
      </Modal>
    );
  }
}
