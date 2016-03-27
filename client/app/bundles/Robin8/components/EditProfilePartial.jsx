import React, { Component } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux'
import { SplitButton } from 'react-bootstrap';
import _ from 'lodash';
import Keyword from './profile/KeyWord';
import Input, { Textarea, RadioButtons } from './profile/Input';
import { reduxForm } from 'redux-form';

import "profile.scss";

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
    _.bindAll(this, ['_fetchBrandProfile', '_updateBrandProfile']);
  }

  componentDidMount() {
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
    // const brand = this.props.brand;
    const { handleSubmit, submitting, invalid } = this.props;
    // const { updateCampaign } = this.props.actions;

    return (
      <div className="wrapper">
        <div className="container profile">
          { this.render_breadcrumb() }
          <form onSubmit={ (event) => { handleSubmit(this._updateBrandProfile)(event).catch(validateFailed) } }>
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
                <Textarea field={description} id="desc" label="品牌介绍" />

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
