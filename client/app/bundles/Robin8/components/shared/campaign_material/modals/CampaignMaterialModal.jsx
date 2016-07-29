import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';
import validator from 'validator';

import { campaignMaterialType } from '../../../../helpers/CampaignHelper'

export default class CampaignMaterialModal extends Component {

  handleClick() {
    const onHide = this.props.onHide;
    const handleUrlClick  = this.props.handleUrlClick;
    const type = this.props.type;
    if (validator.isURL(this.refs.materialUrlInput.value.trim(), { require_protocol: false })) {
      handleUrlClick(type, this.refs.materialUrlInput.value.trim());
      onHide();
    }
  }

  handleChange(e) {
    if (validator.isURL(this.refs.materialUrlInput.value.trim(), { require_protocol: false })) {
      $('.error-tip').hide();
    } else {
      $('.error-tip').show();
    }
  }

  render() {
    const type = this.props.type
    return (
      <Modal {...this.props} className="campaign-material-modal">
        <Modal.Header closeButton>
          <Modal.Title>请输入{ campaignMaterialType(type) }链接地址</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div>
            <input ref='materialUrlInput' onChange={this.handleChange.bind(this)} className='material-url-input' type="text" />
            <p className="error-tip" style={{display: 'none'}}>链接地址格式错误</p>
          </div>
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.handleClick.bind(this)}>确定</Button>
        </Modal.Footer>
      </Modal>
    );
  }
}
