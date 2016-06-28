import React from 'react';
import { reduxForm } from 'redux-form';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import _ from 'lodash'

import "campaign/activity/form.scss";

import BreadCrumb              from './shared/BreadCrumb';
import IntroPartial            from './campaigns/form/IntroPartial';
import TargetPartial           from './campaigns/form/TargetPartial';
import DetailPartial           from './campaigns/form/DetailPartial';
import DatePartial             from './campaigns/form/DatePartial';
import BudgetPartial           from './campaigns/form/BudgetPartial';
import RevokeConfirmModal      from './campaigns/modals/RevokeConfirmModal';

import initToolTip             from './shared/InitToolTip';
import CampaignFormValidate    from './shared/validate/CampaignFormValidate'
import CampaignRejectReasons   from './shared/CampaignRejectReasons'

import { canEditCampaign, canPayCampaign } from '../helpers/CampaignHelper'

const validate = new CampaignFormValidate({
  name: { require: true },
  description: { require: true },
  url: { require: true, url: { require_protocol: true } },
  img_url: { require_img: true },
  budget: { require: true, min_budget: 100 },
  per_action_budget: { require: true },
  action_url: {url: { require_protocol: true }},
  short_url: {url: { require_protocol: true }}
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

class UpdateCampaignPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_fetchCampaign', '_updateCampaign', '_renderRevokeModal']);
    this.state = {
      showRevokeConfirmModal: false
    };
  }

  closeRevokeConfirmModal() {
    this.setState({showRevokeConfirmModal: false});
  }

  _fetchCampaign() {
    const campaign_id = this.props.params.id;
    const { fetchCampaign } = this.props.actions;
    fetchCampaign(campaign_id);
  }

  _updateCampaign() {
    const { updateCampaign } = this.props.actions;
    const campaign_id = this.props.params.id;
    const campaign_fields = this.props.values;
    updateCampaign(campaign_id, campaign_fields);
  }

  componentDidMount() {
    initToolTip({placement:'bottom', html: true});
    this._fetchCampaign();
  }

  renderRejectReasons() {
    const campaign = this.props.campaign;
    if (campaign.get('status') === 'rejected') {
      return <CampaignRejectReasons campaign={campaign} />
    }
  }

  _renderRevokeModal() {
    this.setState({showRevokeConfirmModal: true});
  }

  renderSubmitOrRevokeBtn() {
    const campaign = this.props.campaign;
    const { handleSubmit, submitting, invalid } = this.props;
    if (canEditCampaign(campaign.get("status")) || canPayCampaign(campaign.get("status"))) {
      return (
        <div className="submit-or-revoke">
          <button type="submit" className="btn btn-blue submit-campaign" disabled={ submitting }>重新提交</button>
          <a onClick={this._renderRevokeModal} className="btn revoke-campaign">撤销活动</a>
        </div>
      )
    }
  }

  render() {
    const { name, description, img_url, url, age, province, city, gender, message, budget, per_budget_type, action_url, action_url_identifier, short_url, start_time, per_action_budget, deadline, per_budget_collect_type } = this.props.fields;
    const brand = this.props.brand;
    const campaign = this.props.campaign;
    const { handleSubmit, submitting, invalid } = this.props;
    const { updateCampaign } = this.props.actions;

    return (
      <div className="page page-activity page-activity-edit">
        <div className="container">
          <BreadCrumb />
          {this.renderRejectReasons()}
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(this._updateCampaign)(event).catch(validateFailed) } }>
              <IntroPartial {...{ name, description, img_url, url }}/>
              <BudgetPartial {...{ budget }} isEdit={true} budgetEditable={campaign.get("budget_editable")} />
              <DetailPartial {...{ per_budget_type, action_url_identifier, action_url, short_url, per_action_budget, brand, per_budget_collect_type }} />
              <DatePartial {...{ start_time, deadline }} />
              <div className="creat-form-footer">
                <p className="help-block">我们会在24小时内审核活动并短信通知您, 活动一旦通过审核将不能更改</p>
                {this.renderSubmitOrRevokeBtn()}
              </div>
            </form>
          </div>
        </div>
        <RevokeConfirmModal show={this.state.showRevokeConfirmModal} onHide={this.closeRevokeConfirmModal.bind(this)} actions={this.props.actions} campaignId={campaign.get("id")} />
      </div>
    )
  }
}

UpdateCampaignPartial = reduxForm({
  form: 'activity_form',
  fields: ['name', 'description', 'img_url', 'url', 'age', 'province', 'city', 'gender', 'message', 'budget', 'per_budget_type', 'action_url', 'action_url_identifier' ,'short_url', 'start_time', 'per_action_budget', 'deadline', 'per_budget_collect_type'],
  returnRejectedSubmitPromise: true,
  validate
},

state => ({
  initialValues: state.campaignReducer.get("campaign").toJSON()
})
)(UpdateCampaignPartial);

export default connect(select)(UpdateCampaignPartial)
