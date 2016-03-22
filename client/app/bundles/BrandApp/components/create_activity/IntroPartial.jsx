import React from 'react';
import { Modal, Button } from 'react-bootstrap';
import BaseComponent from '../base';
import 'jcrop-0.9.12';
import 'jcrop-0.9.12/css/jquery.Jcrop.min.css';

class IntroPartial extends BaseComponent {
  constructor(props) {
    super(props);
    this.state = {
      showModal: false,

    };
    this._bind('close', 'open', 'initCrop');
  }

  componentDidMount() {
    const component = this;

    imagePreviewer({
      input: '#coverUpload',
      onload: function(){
        component.setState({imageReader: this.reader});
        component.open();
      }
    });
  }

  close() {
    this.setState({ showModal: false });
  }

  open() {
    this.setState({ showModal: true });
  }

  setCoords(c) {
    // here to upload image
    console.log(c.x, c.y, c.x2, c.y2, c.w, c.h);
  }

  initCrop() {
    const _this = this;

    $('#coverPhotoPlaceholder')[0].src = this.state.imageReader.result;
    $('#coverPhotoPlaceholder').Jcrop({
      onSelect:    _this.setCoords,
      bgColor:     'black',
      keySupport: false,
      bgOpacity:   .4,
      setSelect:   [ 100, 100, 200, 200 ],
    });
  }

  render() {
    return (
      <div className="creat-activity-form creat-intro">
        <div className="header">
          <h3 className="tit">推广简介&nbsp;<span className="what">?</span></h3>
        </div>
        <div className="content">
          <div className="creat-activity-basic-intro">
            <div className="cover-photo">
              <div className="inner">
                <div className="form-control-file">
                  <span className="btn-upload">上传图片</span>
                  <input {...this.props.image} value={ null } type="file" id="coverUpload" />
                </div>
              </div>
            </div>
            <div className="basic-intro">
              <div className="form-group">
                <label htmlFor="activityTitle">活动标题</label>
                <input type="text" className="form-control activity-title-input" maxLength={20} placeholder="请概括您的推广，让您的内容一目了然" required {...this.props.title} />
                <span className="word-limit">20</span>
              </div>
              <div className="form-group">
                <label htmlFor="activityIntro">活动简介</label>
                <textarea name className="form-control activity-intro-input" maxLength={140} placeholder="请简要介绍您的推广，帮助媒体了解如何能够更好的帮您传播，请给出适当的列子，如：请 先评论棒极了，再给出买家秀" required defaultValue={""} {...this.props.intro} />
                <span className="word-limit">140</span>
              </div>
            </div>
          </div>
        </div>

        <Modal show={this.state.showModal} onHide={this.close} onEntered={this.initCrop}>
          <Modal.Body>
            <img id="coverPhotoPlaceholder" style={{maxWidth: '100%'}} />
          </Modal.Body>
          <Modal.Footer>
            <Button onClick={this.close}>Close</Button>
          </Modal.Footer>
        </Modal>

      </div>
    );
  }
}

export default IntroPartial;
