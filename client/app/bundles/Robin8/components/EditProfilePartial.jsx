import React, { Component } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux'
import { SplitButton } from 'react-bootstrap';
import _ from 'lodash';
import Keyword from './profile/KeyWord';
import Crop from './shared/Crop';
import Input, { Textarea, RadioButtons } from './profile/Input';
import { reduxForm } from 'redux-form';
import 'qiniu-js/dist/qiniu.min.js';
import "profile.scss";

const getUploader = function() {
  return Qiniu.uploader({
      runtimes: 'html5,flash,html4',      // 上传模式,依次退化
      browse_button: 'foo',      // 上传选择的点选按钮，**必需**
      uptoken_url: '/qiniu_upload_token', // Ajax 请求 uptoken 的 Url，**强烈建议设置**（服务端提供）
      get_new_uptoken: false,             // 设置上传文件的时候是否每次都重新获取新的 uptoken
      unique_names: true,                 // 默认 false，key 为文件名。若开启该选项，JS-SDK 会为每个文件自动生成key（文件名）
      domain: 'robin8',                   // bucket 域名，下载资源时用到，**必需**
      max_file_size: '100mb',             // 最大文件体积限制
      flash_swf_url: 'path/of/plupload/Moxie.swf',  //引入 flash,相对路径
      max_retries: 3,                     // 上传失败最大重试次数
      chunk_size: '4mb',                  // 分块上传时，每块的体积
      multi_selection: false,
      init: {}
  });
}

const validate = new FormValidate({
  name: { require: true },
  description: { require: true },
  real_name: { require: true },
  mobile_number: { require: true },
  email: { require: true },
  url: { require: true, url: { require_protocol: false} }
})

const validateFailed = (errors) => {
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
}

function select(state) {
  return { brand: state.$$brandStore.get("brand") }
}


class EditProfilePartial extends Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_fetchBrandProfile', '_updateBrandProfile', 'upload']);
  }

  upload(size, scale) {
    this.uploader.refresh();
    this.uploader.addFile(this.refs.fileInput.files[0]);

    this.uploader.bind("FileUploaded", function(up, file, info) {
      window.xx = arguments
      const url = `http://7xozqe.com2.z0.glb.qiniucdn.com/${file.target_name}?imageMogr2/crop/!${size.w * scale}x${size.h * scale}a${size.x * scale}a${size.y * scale}`;
      $('#logo-part img').prop('src', url);

      // url就是裁切后的logo地址，找个办法存起来吧
    });

    this.uploader.start();
  }

  componentDidMount() {
    this.uploader = getUploader();
    this._fetchBrandProfile();
  }

  _fetchBrandProfile() {
    const { fetchBrandProfile } = this.props.actions;
    fetchBrandProfile();
  }

  _updateBrandProfile() {
    const { updateBrandProfile } = this.props.actions;
    const profile_fields = this.props.values;
    updateBrandProfile(profile_fields);
  }

  render_breadcrumb() {
    return (
      <ol className="breadcrumb">
        <li>
          <i className="caret-arrow left" />
          <Link to="/brand/">我的主页</Link>
        </li>
      </ol>
    );
  }

  render() {
    const { name, url, description, email, real_name, mobile_number, keywords} = this.props.fields;
    const readyState = this.props.data.get("readyState");
    const { handleSubmit, submitting, invalid } = this.props;
    console.log("-----edit profile-----")
    return (
      <div className="wrapper">
        <div className="container profile">
          { this.render_breadcrumb() }
          <form onSubmit={ (event) => { handleSubmit(this._updateBrandProfile)(event).catch(validateFailed) } }>
            <div className="header">
              <h3>推广简介</h3>
            </div>

            <div className="base-info">
              <div className="logo-part" id="logo-part">
                <img ref="logo" src="http://dummyimage.com/300x300/4d494d/686a82.gif&text=placeholder+image" alt="placeholder+image" />

                {/* 这个input为了配合Crop，不要使用这个做上传（不要设置name） */}
                <input ref="fileInput" id="fileInput" type="file" style={{display: 'none'}}/>

                {/* 七牛的bug， 没这个元素不行 */}
                <button type="button" id="foo" className="btn btn-blue" style={{display: 'none'}}>上传品牌LOGO</button>

                <label htmlFor="fileInput" id="uploadButton" className="btn btn-blue">上传品牌LOGO</label>
              </div>

              <div className="form-part">
                <Input field={name} id="name" label="品牌名称" />
                <Input field={url} id="url" label="官方网站" />
                <Textarea field={description} id="desc" label="品牌介绍" />

                <div className="form-group">
                  <label htmlFor="desc" className="control-label">品牌关键词</label>
                  <div className="control-input" style={{textAlign: 'left', paddingTop: '10px'}}>
                    <Keyword field={keywords} readyState={readyState} />
                  </div>
                </div>

              </div>
            </div>

            <div className="header contacter-header">
              <h3>联系人信息</h3>
            </div>

            <div className="contacter-info">
              <Input field={real_name} id="contacter-name" label="真实姓名" />
              <Input field={mobile_number} id="contacter-phone" label="联系号码" />
              <Input field={email} id="contacter-email" label="电子邮箱" />
            </div>

            <div className="options">
              <button className="btn btn-blue" type="submit">保存</button>
              <button className="btn btn-red">取消</button>
            </div>
          </form>
        </div>
        <Crop fileInputSelector={"#fileInput"} doCrop={this.upload} />
      </div>
    );
  }
}

EditProfilePartial = reduxForm({
  form: 'profile_form',
  fields: ['name', 'url', 'description', 'email', 'real_name', 'mobile_number', 'keywords'],
  returnRejectedSubmitPromise: true,
  validate
},
state => ({
  initialValues: state.$$brandStore.get("brand").toJSON()
})
)(EditProfilePartial);

export default connect(select)(EditProfilePartial);
