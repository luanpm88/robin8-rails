import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import _  from 'lodash';
import moment from 'moment';

import "campaign/recruit/form.scss";

import BreadCrumb               from './shared/BreadCrumb';
import IntroPartial             from "./recruit_campaigns/form/IntroPartial";
import CreateMaterialsPartial   from './shared/campaign_material/CreateMaterialsPartial'
import DatePartial              from './recruit_campaigns/form/OfflineDate';
import RecruitDatePartial       from './recruit_campaigns/form/RecruitDatePartial';
import RecruitBudgetPartial     from './recruit_campaigns/form/RecruitBudgetPartial';
import RevokeConfirmModal       from './campaigns/modals/RevokeConfirmModal';
import RecruitTargetPartial     from './recruit_campaigns/form/RecruitTargetPartial';

import initToolTip              from './shared/InitToolTip';
import CampaignFormValidate     from './shared/validate/CampaignFormValidate'
import CampaignRejectReasons    from './shared/CampaignRejectReasons'

import { canEditCampaign, canPayCampaign } from '../helpers/CampaignHelper'

const validate = new CampaignFormValidate({
  name: { require: true },
  description: { require: true },
  img_url: { require_img: true },
  budget: { require: true},
  per_action_budget: { require: true },
  action_url: {url: { require_protocol: false }},
  short_url: {url: { require_protocol: true }},
  task_description: { require: true }
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
    campaign: state.campaignReducer.get("campaign")
  };
}

class UpdateRecruitCampaignPartial extends React.Component{
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
    const { fetchRecruit } = this.props.actions;
    fetchRecruit(campaign_id);
  }

  _updateCampaign() {
    const { updateRecruit } = this.props.actions;
    const campaign_id = this.props.params.id;
    const campaign_fields = this.props.values;
    updateRecruit(campaign_id, campaign_fields);
  }

  componentDidMount() {
    this._fetchCampaign();
    initToolTip({placement:'bottom', html: true});
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
    const { name, description, img_url, professions, start_time, deadline,
          recruit_start_time, recruit_end_time, budget, per_action_budget,
          recruit_person_count, task_description, address, region, sns_platforms,
          hide_brand_name, materials, material_ids
        } = this.props.fields;
    const { handleSubmit, submitting, invalid } = this.props;
    const { campaign } = this.props;
    const { saveRecruit } = this.props.actions;
    return(
      <div className="page page-recruit page-recruit-new">
        <div className="container">
          <BreadCrumb />
          {this.renderRejectReasons()}
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(this._updateCampaign)(event).catch(validateFailed) }}>
              <IntroPartial {...{name, description, img_url, task_description, address, hide_brand_name}}/>
              {<CreateMaterialsPartial {...{materials, material_ids}} />}
              <RecruitDatePartial {...{ recruit_start_time, recruit_end_time }} />
              <DatePartial {...{ start_time, deadline }} />
              <RecruitBudgetPartial {...{budget, per_action_budget, recruit_person_count}} budgetEditable={campaign.get("budget_editable")} />
              <RecruitTargetPartial {...{region, professions, sns_platforms}}/>
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

UpdateRecruitCampaignPartial = reduxForm({
  form: "recruit_campaign_form",
  fields: ["name", "description", "img_url", "url", "professions", "start_time",
         "deadline", "recruit_start_time", "recruit_end_time", "budget", "per_action_budget",
         "recruit_person_count", "task_description", 'address', "region", "sns_platforms", "hide_brand_name", "materials", "material_ids"],
  returnRejectedSubmitPromise: true,
  validate
},
state => ({
  initialValues: state.campaignReducer.get("campaign").toJSON()
})
)(UpdateRecruitCampaignPartial);

export default connect(select)(UpdateRecruitCampaignPartial);
