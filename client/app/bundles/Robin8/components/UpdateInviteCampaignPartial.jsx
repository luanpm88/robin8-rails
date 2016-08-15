import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import _  from 'lodash';
import moment from 'moment';

import "campaign/invite/form.scss";

import BreadCrumb            from './shared/BreadCrumb';
import IntroPartial          from "./invite_campaigns/form/IntroPartial";
import DatePartial           from './invite_campaigns/form/OfflineDate';
import KolSelectPartial      from './invite_campaigns/form/KolSelectPartial';
import initToolTip           from './shared/InitToolTip';
import CampaignFormValidate  from './shared/validate/CampaignFormValidate'
import CreateMaterialsPartial  from './shared/campaign_material/CreateMaterialsPartial'
import CampaignRejectReasons from './shared/CampaignRejectReasons'
import RevokeConfirmModal      from './campaigns/modals/RevokeConfirmModal';

import { canEditCampaign, canPayCampaign } from '../helpers/CampaignHelper'

const validate = new CampaignFormValidate({
  name: { require: true },
  description: { require: true },
  img_url: { require_img: true },
  budget: { require: false }
})

const validateFailed = (errors) => {
  console.log(errors);
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
  if ( (Object.keys(errors).length === 1) && errors["img_url"]) {
    $("html,body").animate({scrollTop: $(".cover-photo").offset().top}, 100);
  }
}

function select(state){
  return {
    brand: state.profileReducer.get("brand"),
    campaign: state.campaignReducer.get("campaign"),
    selected_social_accounts: state.campaignReducer.getIn(["campaign", "selected_social_accounts"])
  };
}

class UpdateInviteCampaignPartial extends React.Component{
  constructor(props, context){
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
    const { fetchInvite } = this.props.actions;
    fetchInvite(campaign_id);
  }

  _updateCampaign() {
    const { updateInvite } = this.props.actions;
    const campaign_id = this.props.params.id;
    const campaign_fields = this.props.values;
    updateInvite(campaign_id, campaign_fields);
  }

  componentDidMount() {
    this._fetchCampaign();
    initToolTip({placement:'bottom', html: true});
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
    if (canEditCampaign(campaign.get("status")) || canPayCampaign(campaign.get("status"))) {
      return (
        <div className="submit-or-revoke">
          <button type="submit" className="btn btn-blue submit-campaign" disabled={ submitting }>重新提交</button>
          <a onClick={this._renderRevokeModal} className="btn revoke-campaign">撤销活动</a>
        </div>
      )
    }
  }


  render(){
    const { name, description, img_url, start_time, deadline,
            budget, social_accounts, materials, material_ids} = this.props.fields;
    const { handleSubmit, submitting, invalid, campaign, actions, selected_social_accounts } = this.props;

    return(
      <div className="page page-invite page-invite-new">
        <div className="container">
          <BreadCrumb />
          {this.renderRejectReasons()}
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(this._updateCampaign)(event).catch(validateFailed) }}>
              <IntroPartial {...{name, description, img_url}}/>
              <CreateMaterialsPartial {...{materials, material_ids}} />
              <DatePartial {...{ start_time, deadline }} />
              <KolSelectPartial {...{ budget, social_accounts, selected_social_accounts }} />
              <div className="creat-form-footer">
                <p className="help-block">活动一旦通过审核将不能更改，我们将在2小时内审核当日10:00 - 18:00提交的订单，其余时间段提交的订单次日审核</p>
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

UpdateInviteCampaignPartial = reduxForm({
  form: "invite_campaign_form",
  fields: ["name", "description", "img_url", "start_time", "deadline",
           "social_accounts", "budget", "materials", "material_ids"],
  returnRejectedSubmitPromise: true,
  validate
},
state => {
  return {
    initialValues: state.campaignReducer.get("campaign").toJSON()
  };
}
)(UpdateInviteCampaignPartial);

export default connect(select)(UpdateInviteCampaignPartial);
