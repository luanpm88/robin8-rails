import React, { Component } from 'react';
import { Modal, Button } from 'react-bootstrap';
import 'jcrop-0.9.12';
import 'jcrop-0.9.12/css/jquery.Jcrop.min.css';

export default class Crop extends Component {
  constructor(props) {
    super(props);

    this.state = {
      showModal: false,
    };

    const that = this;

    that.bindChangeEvent()

    this.close = this.close.bind(this);
    this.open = this.open.bind(this);
    this.initCrop = this.initCrop.bind(this);
    this.doCrop = this.doCrop.bind(this);
    this.onSelect = this.onSelect.bind(this);
    this.reset = this.reset.bind(this);
  }

  reset() {
    $(this.props.fileInputSelector).prop('value', '');
  }

  bindChangeEvent() {
    const that = this;

    $(document).on('change', this.props.fileInputSelector, function(e) {
      var files = e.target.files;
      if(FileReader && files && files.length) {
        var reader = new FileReader();
        reader.onload = function() {
          var image = new Image();
          image.src = reader.result;

          image.onload = function() {
            that.originalWidth = this.width;
          }

          that.image = reader.result;
          that.open();
        };
        reader.readAsDataURL(this.files[0]);
      }
      else {
        alert("Your browser doesn't support file upload!");
      }
    });
  }

  close() {
    this.setState({ showModal: false });
  }

  open() {
    this.setState({ showModal: true });
  }

  doCrop(){
    const scale = this.originalWidth / $('#cropImage').width();
    this.props.doCrop(this.size, scale);
    this.close();
  }

  onSelect(size) {
    this.size = size;
  }

  initCrop() {
    const that = this;

    $('#cropImage')[0].src = that.image;

    $('#cropImage').Jcrop({
      allowSelect : false,
      onSelect:    that.onSelect,
      bgColor:     'black',
      keySupport: false,
      bgOpacity:   .4,
      setSelect:   [ 0, 0, 300, 300 ],
      aspectRatio: 1,
      onRelease : function(){ this.setOptions({ setSelect: [ 0, 0, 300, 300 ] }) }
    });
  }

  render() {
    return (
      <div>
        <Modal show={this.state.showModal} onHide={this.close} onEntered={this.initCrop} onExit={this.reset}>
          <Modal.Body>
            <img id="cropImage" style={{maxWidth: '100%'}} />
          </Modal.Body>
          <Modal.Footer>
            <Button onClick={this.doCrop}>裁切 & 上传</Button>
            <Button onClick={this.close}>关闭</Button>
          </Modal.Footer>
        </Modal>
      </div>
    );
  }
}
