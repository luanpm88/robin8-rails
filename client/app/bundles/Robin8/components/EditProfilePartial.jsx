import React, { Component } from 'react';
import { Link } from 'react-router';
import { SplitButton } from 'react-bootstrap';
import Keyword from './profile/KeyWord';
import Input, { Textarea, RadioButtons } from './profile/Input';
import { reduxForm } from 'redux-form';

import "profile.scss";

const validate = new FormValidate({
  name: { require: true },
  desc: { require: true },
  contacter_name: { require: true },
  contacter_phone: { require: true },
  contacter_email: { require: true },
  contacter_rate: { require: true },
  url: { require: true, url: { require_protocol: false} }
})

const validateFailed = (errors) => {
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
}

class EditProfilePartial extends Component {
  _updateProfile() {
    /* 修改的逻辑 */
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
    const { name, url, desc, contacter_email, contacter_name, contacter_phone, keywords, contacter_rate} = this.props.fields;
    // const brand = this.props.brand;
    const { handleSubmit, submitting, invalid } = this.props;
    // const { updateCampaign } = this.props.actions;

    return (
      <div className="wrapper">
        <div className="container profile">
          { this.render_breadcrumb() }
          <form onSubmit={ (event) => { handleSubmit(this._updateProfile)(event).catch(validateFailed) } }>
            <div className="header">
              <h3>推广简介</h3>
            </div>

            <div className="base-info">
              <div className="logo-part">
                <img src="http://dummyimage.com/300x300/4d494d/686a82.gif&text=placeholder+image" alt="placeholder+image" />
                <button className="btn btn-blue">上传品牌LOGO</button>
              </div>

              <div className="form-part">
                <Input field={name} id="name" label="品牌名称" />
                <Input field={url} id="url" label="官方网站" />
                <Textarea field={desc} id="desc" label="品牌介绍" />

                <div className="form-group">
                  <label htmlFor="desc" className="control-label">品牌关键词</label>
                  <div className="control-input" style={{textAlign: 'left', paddingTop: '10px'}}>
                    <Keyword field={keywords} />
                  </div>
                </div>

              </div>
            </div>

            <div className="header contacter-header">
              <h3>联系人信息</h3>
            </div>

            <div className="contacter-info">
              <Input field={contacter_name} id="contacter-name" label="真实姓名" />
              <Input field={contacter_phone} id="contacter-phone" label="联系号码" />
              <Input field={contacter_email} id="contacter-email" label="电子邮箱" />
              <RadioButtons field={contacter_rate} label="短信联系频率" collection={[["每次更新", "0"], ["每天更新概况", "1"], ["不联系", "2"]]} />
            </div>

            <div className="options">
              <button className="btn btn-blue" type="submit">保存</button>
              <button className="btn btn-red">取消</button>
            </div>
          </form>
        </div>
      </div>
    );
  }
}

EditProfilePartial = reduxForm({
  form: 'activity_form',
  fields: ['name', 'url', 'desc', 'contacter_email', 'contacter_name', 'contacter_phone', 'keywords', 'contacter_rate'],
  returnRejectedSubmitPromise: true,
  validate
},
state => ({
  initialValues: {
    name: '美年达',
    url: 'www.baidu.com',
    desc: '呵呵呵呵',
    contacter_name: '123',
    contacter_phone: '1831231232',
    contacter_email: 'a@a.com',
    contacter_rate: "1",
    keywords: '家庭,父母,子女'
  }
})
)(EditProfilePartial);

export default EditProfilePartial;