import React, { Component } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux'
import { reduxForm } from 'redux-form';
import { SplitButton } from 'react-bootstrap';
import _ from 'lodash';

import BreadCrumb     from './shared/BreadCrumb';
import Keyword from './profile/KeyWord';
import Crop from './shared/Crop';
import Input, { Textarea, RadioButtons } from './profile/Input';

import {} from './shared/plupload.full.min'
import 'qiniu-js/dist/qiniu.min.js';
import BrandFormValidate from './shared/validate/BrandFormValidate'

import "user/profile.scss";

const getUploader = function() {
  return Qiniu.uploader({
      runtimes: 'html5,flash,html4',      // 上传模式,依次退化
      browse_button: 'foo',      // 上传选择的点选按钮，**必需**
      uptoken_url: '/brand_api/v1/util/qiniu_token', // Ajax 请求 uptoken 的 Url，**强烈建议设置**（服务端提供）
      get_new_uptoken: false,             // 设置上传文件的时候是否每次都重新获取新的 uptoken
      unique_names: true,                 // 默认 false，key 为文件名。若开启该选项，JS-SDK 会为每个文件自动生成key（文件名）
      domain: '7xozqe.com1.z0.glb.clouddn.com',                   // bucket 域名，下载资源时用到，**必需**
      max_file_size: '100mb',             // 最大文件体积限制
      flash_swf_url: 'path/of/plupload/Moxie.swf',  //引入 flash,相对路径
      max_retries: 3,                     // 上传失败最大重试次数
      chunk_size: '4mb',                  // 分块上传时，每块的体积
      multi_selection: false,
      init: {}
  });
}

const validate = new BrandFormValidate({
  name: { require: true },
  description: { require: true },
  real_name: { require: true },
  campany_name: { require: true },
  url: { url: { require_protocol: false} }
})

const validateFailed = (errors) => {
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
}

function select(state) {
  return { brand: state.profileReducer.get("brand") }
}


class EditProfilePartial extends Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_fetchBrandProfile', '_updateBrandProfile', '_upload', '_cancelSubmitForm']);
  }

  _cancelSubmitForm(e) {
    e.preventDefault();
    this.props.history.push('/brand/');
  }

  _upload(size, scale) {
    this.uploader.refresh();
    this.uploader.addFile(this.refs.fileInput.files[0]);
    this.uploader.bind("FileUploaded", function(up, file, info) {
      const domain = up.getOption('domain');
      const url = 'http://' + domain + `/${file.target_name}?imageMogr2/crop/!${size.w * scale}x${size.h * scale}a${size.x * scale}a${size.y * scale}`;
      $('#logo-part img').prop('src', url);

      // 保存url
      fetch('/brand_api/v1/user/avatar', {
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
        },
        credentials: "same-origin",
        method: 'PUT',
        body: JSON.stringify({avatar_url: url})
      })
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

  render() {
    const { name, url, description, real_name, keywords, campany_name} = this.props.fields;
    const { handleSubmit, submitting, invalid } = this.props;
    const brand = this.props.brand

    console.log(this.props);
    return (
      <div className="page page-profile page-profile-edit">
        <div className="container">
          <BreadCrumb />
          <form onSubmit={ (event) => { handleSubmit(this._updateBrandProfile)(event).catch(validateFailed) } }>
            <div className="header">
              <h3>品牌简介</h3>
            </div>

            <div className="base-info">
              <div className="logo-part" id="logo-part">
                { do
                  {
                    if (brand.get("avatar_url"))
                      <img ref="logo" src={brand.get("avatar_url")} alt="placeholder+image" />
                    else
                      <img ref="logo" src={require('brand-profile-pic.jpg')} />
                  }
                }

                {/* 这个input为了配合Crop，不要使用这个做上传（不要设置name） */}
                <input ref="fileInput" id="fileInput" type="file" style={{display: 'none'}}/>

                {/* 七牛的bug， 没这个元素不行 */}
                <button type="button" id="foo" className="btn btn-blue" style={{display: 'none'}}>上传品牌LOGO</button>

                <label htmlFor="fileInput" id="uploadButton" className="btn btn-blue">上传品牌LOGO</label>
              </div>

              <div className="form-part">
                <Input field={name} id="name" label="品牌名称" placeholder="必填" />
                <Input field={campany_name} id="campany_name" label="公司名称" placeholder="必填" />
                <Input field={url} id="url" label="官方网站" placeholder="选填" />
                <Textarea field={description} id="desc" label="品牌介绍" placeholder="必填" />

                <div className="form-group">
                  <label htmlFor="desc" className="control-label">品牌关键词</label>
                  <div className="control-input">
                    <Keyword field={keywords} />
                  </div>
                </div>

              </div>
            </div>

            <div className="header contacter-header">
              <h3>联系人信息</h3>
            </div>

            <div className="contacter-info">
              <Input field={real_name} id="contacter-name" label="真实姓名" placeholder="必填" />
            </div>

            <div className="options">
              <button className="btn btn-blue" type="submit">保存</button>
              <button className="btn btn-red" onClick={this._cancelSubmitForm}>取消</button>
            </div>
          </form>
        </div>
        <Crop fileInputSelector={"#fileInput"} doCrop={this._upload} aspectRatio={1} />
      </div>
    );
  }
}

EditProfilePartial = reduxForm({
  form: 'profile_form',
  fields: ['name', 'url', 'description', 'real_name', 'keywords', 'campany_name'],
  returnRejectedSubmitPromise: true,
  validate
},
state => ({
  initialValues: state.profileReducer.get("brand").toJSON()
})
)(EditProfilePartial);

export default connect(select)(EditProfilePartial);
