import React from 'react';
import { reduxForm } from 'redux-form';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import _ from 'lodash'

import "campaign/activity/form.scss";

import BreadCrumb              from './shared/BreadCrumb';
import IntroPartial            from './campaigns/form/IntroPartial';
import CampaignFormValidate    from './shared/validate/CampaignFormValidate'

import { canEditCampaign, canPayCampaign } from '../helpers/CampaignHelper'

const validate = new CampaignFormValidate({
  name: { require: true },
  description: { require: true },
  url: { require: true, url: { require_protocol: false } },
  img_url: { require_img: true },
})

const validateFailed = (errors) => {
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
  if ( (Object.keys(errors).length === 1) && errors["img_url"]) {
    $("html,body").animate({scrollTop: $(".cover-photo").offset().top}, 100);
  }
}

function select(state) {
  return {
    brand: state.profileReducer.get("brand"),
    campaign: state.campaignReducer.get("campaign")
  };
}

class UpdateCampaignBasePartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_fetchCampaign', '_updateCampaign', 'renderSubmit']);
  }

  _fetchCampaign() {
    const campaign_id = this.props.params.id;
    const { fetchCampaign } = this.props.actions;
    fetchCampaign(campaign_id);
  }

  _updateCampaign() {
    const { updateCampaignBase } = this.props.actions;
    const campaign_id = this.props.params.id;
    const campaign_fields = this.props.values;
    updateCampaignBase(campaign_id, campaign_fields);
  }

  componentDidMount() {
    this._fetchCampaign();
  }

  componentWillUnmount() {
    this.props.actions.clearCampaign();
  }

  renderSubmit() {
    const campaign = this.props.campaign;
    const { handleSubmit, submitting, invalid } = this.props;
    return (
      <div className="submit-or-revoke">
        <button type="submit" className="btn btn-blue submit-campaign" disabled={ submitting }>重新提交</button>
      </div>
    )
  }

  render() {
    const { name, description, img_url, url } = this.props.fields;
    const brand = this.props.brand;
    const campaign = this.props.campaign;
    const { handleSubmit, submitting, invalid } = this.props;

    return (
      <div className="page page-activity page-activity-edit">
        <div className="container">
          <BreadCrumb />
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(this._updateCampaign)(event).catch(validateFailed) } }>
              <IntroPartial {...{ name, description, img_url, url }}/>
              <div className="creat-form-footer">
                <p className="help-block">活动审核后只有管理员才能修改推广素材</p>
                {this.renderSubmit()}
              </div>
            </form>
          </div>
          <div id="sublist"></div>
        </div>
      </div>
    )
  }
}

UpdateCampaignBasePartial = reduxForm({
  form: 'activity_form',
  fields: ['name', 'description', 'img_url', 'url'],
  returnRejectedSubmitPromise: true,
  validate
},

state => ({
  initialValues: state.campaignReducer.get("campaign").toJSON()
})
)(UpdateCampaignBasePartial);

export default connect(select)(UpdateCampaignBasePartial)
