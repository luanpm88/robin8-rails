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

import { adminCanEditCampaign, canPayCampaign } from '../helpers/CampaignHelper'

const validate = new CampaignFormValidate({
  name: { require: true },
  description: { require: true },
  url: { require: true, url: { require_protocol: false } },
  img_url: { require_img: true },
  per_action_budget: { require: true },
  action_url: {url: { require_protocol: false }},
  short_url: {url: { require_protocol: true }},
  sub_type: { require: true },
  example_screenshot_count: { require: true },
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

  componentWillUnmount() {
    this.props.actions.clearCampaign();
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
    if (adminCanEditCampaign(campaign.get("status")) || canPayCampaign(campaign.get("status"))) {
      return (
        <div className="submit-or-revoke">
          <button type="submit" className="btn btn-blue submit-campaign" disabled={ submitting }>重新提交</button>
          <a onClick={this._renderRevokeModal} className="btn revoke-campaign">撤销活动</a>
        </div>
      )
    }
  }

  render() {
    const { name, description, img_url, url, age, region, tags, gender, message, budget, per_budget_type, action_url, action_url_identifier, short_url, start_time, per_action_budget, deadline, per_budget_collect_type, sub_type, example_screenshot_count } = this.props.fields;
    const brand = this.props.brand;
    const campaign = this.props.campaign;
    const min_budget = brand.get("campaign_min_budget");
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
              <BudgetPartial {...{ budget, min_budget }} isEdit={true} budgetEditable={campaign.get("budget_editable")} />
              <DetailPartial {...{ per_budget_type, action_url_identifier, action_url, short_url, per_action_budget, brand, per_budget_collect_type, sub_type, example_screenshot_count }} />
              <DatePartial {...{ start_time, deadline }} />
              <TargetPartial {...{region, tags, age, gender}} />
              <div className="creat-form-footer">
                <p className="help-block">我们会在24小时内审核活动并短信通知您, 活动一旦通过审核将不能更改</p>
                {this.renderSubmitOrRevokeBtn()}
              </div>
            </form>
          </div>
          <div id="sublist"></div>
        </div>
        <RevokeConfirmModal show={this.state.showRevokeConfirmModal} onHide={this.closeRevokeConfirmModal.bind(this)} actions={this.props.actions} campaignId={campaign.get("id")} />
      </div>
    )
  }
}

UpdateCampaignPartial = reduxForm({
  form: 'activity_form',
  fields: ['name', 'description', 'img_url', 'url', 'age', 'region', 'tags', 'gender', 'message', 'budget', 'per_budget_type', 'action_url', 'action_url_identifier' ,'short_url', 'start_time', 'per_action_budget', 'deadline', 'per_budget_collect_type', 'sub_type', 'example_screenshot_count'],
  returnRejectedSubmitPromise: true,
  validate
},

state => ({
  initialValues: state.campaignReducer.get("campaign").toJSON()
})
)(UpdateCampaignPartial);

export default connect(select)(UpdateCampaignPartial)
