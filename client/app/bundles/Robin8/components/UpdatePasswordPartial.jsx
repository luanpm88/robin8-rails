import React, { Component } from 'react';
import { Link } from 'react-router';
import Input from './profile/Input';
import { reduxForm } from 'redux-form';
import BrandFormValidate from './shared/validate/BrandFormValidate'

import "user/profile.scss";

const validate = new BrandFormValidate({
  password: {require: true, min_length: 6},
  new_password: {require: true, min_length: 6},
  new_password_confirmation: {require: true, new_password_confirmation: true}
})

const validateFailed = (errors) => {
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
}

class UpdatePasswordPartial extends Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_updateBrandPassword', '_cancelSubmitForm']);
  }

  _updateBrandPassword() {
    const password_fields = this.props.values;
    const { updateBrandPassword } = this.props.actions;
    updateBrandPassword(password_fields);
  }

  _cancelSubmitForm(e) {
    e.preventDefault();
    this.props.history.push('/brand/');
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

    const { password, new_password, new_password_confirmation } = this.props.fields;
    const { handleSubmit, submitting, invalid } = this.props;
    return (
      <div className="page page-profile page-profile-password">
        <div className="container">
          { this.render_breadcrumb() }
          <form onSubmit={ (event) => { handleSubmit(this._updateBrandPassword)(event).catch(validateFailed) } }>            <div className="header contacter-header">
              <h3>修改密码</h3>
            </div>

            <div className="contacter-info">
              <Input field={password} type="password" id="password" label="旧密码" />
              <Input field={new_password} type="password" id="new_password" label="新密码" />
              <Input field={new_password_confirmation} type="password" id="new_password_confirmation" label="确认密码" />
            </div>

            <div className="options">
              <button className="btn btn-blue" type="submit">保存</button>
              <button className="btn btn-red" onClick={this._cancelSubmitForm}>取消</button>
            </div>
          </form>
        </div>
      </div>
    );
  }
}

UpdatePasswordPartial = reduxForm({
  form: 'password_form',
  fields: ['password', 'new_password', 'new_password_confirmation'],
  returnRejectedSubmitPromise: true,
  validate
})(UpdatePasswordPartial)

export default UpdatePasswordPartial;
