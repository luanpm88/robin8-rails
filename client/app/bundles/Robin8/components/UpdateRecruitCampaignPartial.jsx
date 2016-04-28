import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import _  from 'lodash';
import moment from 'moment';

import "campaign/recruit/new.scss";

import IntroPartial from "./create_recruit/IntroPartial";
import RecruitTargetPartial from './create_recruit/RecruitTargetPartial';
import DatePartial from './create_campaign/DatePartial';
import RecruitDatePartial from './create_recruit/RecruitDatePartial';
import RecruitBudgetPartial from './create_recruit/RecruitBudgetPartial';
import initToolTip from './shared/InitToolTip';

const validate = new FormValidate({
  name: { require: true },
  description: { require: true },
  img_url: { require_img: true },
  budget: { require: true},
  per_action_budget: { require: true },
  action_url: {url: { require_protocol: true }},
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
  return { brand: state.$$brandStore.get("brand")};
}

class UpdateRecruitCampaignPartial extends React.Component{
  constructor(props, context){
    super(props, context);
    _.bindAll(this, ['_fetchCampaign', '_updateCampaign']);
  }

  _fetchCampaign() {
    const campaign_id = this.props.params.id;
    const { fetchRecruit } = this.props.actions;
    fetchRecruit(campaign_id);
  }

  _updateCampaign() {
    const { updateRecruit } = this.props.actions;
    const campaign_id = this.props.data.get("campaign").get("id");
    const campaign_fields = this.props.values;
    updateRecruit(campaign_id, campaign_fields);
  }

  componentDidMount() {
    this._fetchCampaign();
    initToolTip({placement:'bottom', html: true});  
  }

  render_breadcrumb(){
    return (
      <ol className="breadcrumb">
        <li>
          <i className="caret-arrow left" />
          <Link to="/brand/">我的主页</Link>
        </li>
      </ol>
    );
  }

  render(){
    const { name, description, img_url, influence_score, start_time, deadline, 
          recruit_start_time, recruit_end_time, budget, per_action_budget, recruit_person_count, task_description, address, region, hide_brand_name} = this.props.fields;
    const { handleSubmit, submitting, invalid } = this.props;
    const { saveRecruit } = this.props.actions;
    return(
      <div className="page page-recruit page-recruit-new">
        <div className="container">
          {this.render_breadcrumb()}
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(this._updateCampaign)(event).catch(validateFailed) }}>
              <IntroPartial {...{name, description, img_url, task_description, address, hide_brand_name}}/>
              <RecruitTargetPartial {...{influence_score, region}}/>
              <RecruitDatePartial {...{ recruit_start_time, recruit_end_time }} />
              <DatePartial {...{ start_time, deadline }} />
              <RecruitBudgetPartial {...{budget, per_action_budget, recruit_person_count}} />
              <div className="creat-form-footer">
                <p className="help-block">活动一旦通过审核将不能更改，我们将在2小时内审核当日10:00 - 18:00提交的订单，其余时间段提交的订单次日审核</p>
                <button type="submit" className="btn btn-blue btn-lg createCampaignSubmit" disabled={ submitting }>完成发布活动</button>
              </div>
            </form>
          </div>
          <div id="sublist"></div>
        </div>
      </div>
    )
  }
}

UpdateRecruitCampaignPartial = reduxForm({
  form: "recruit_campaign_form",
  fields: ["name", "description", "img_url", "url", "influence_score", "start_time",
         "deadline", "recruit_start_time", "recruit_end_time", "budget", "per_action_budget", "recruit_person_count", "task_description", 'address', "region", "hide_brand_name"],
  returnRejectedSubmitPromise: true,
  validate
},
  state => ({
    initialValues: state.$$brandStore.get("campaign").toJSON()
  })
)(UpdateRecruitCampaignPartial);

export default connect(select)(UpdateRecruitCampaignPartial);