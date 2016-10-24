import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import  _ from 'lodash';
import moment from 'moment';

import "campaign/recruit/form.scss";

import BreadCrumb               from './shared/BreadCrumb';
import IntroPartial             from "./recruit_campaigns/form/IntroPartial";
import CreateMaterialsPartial   from './shared/campaign_material/CreateMaterialsPartial'
import DatePartial              from './recruit_campaigns/form/OfflineDate';
import RecruitDatePartial       from './recruit_campaigns/form/RecruitDatePartial';
import RecruitBudgetPartial     from './recruit_campaigns/form/RecruitBudgetPartial';
import RecruitTargetPartial     from './recruit_campaigns/form/RecruitTargetPartial';
import SubTypePartial           from './recruit_campaigns/form/SubTypePartial';

import initToolTip              from './shared/InitToolTip';
import CampaignFormValidate     from './shared/validate/CampaignFormValidate'
import getUrlQueryParams from '../helpers/GetUrlQueryParams'


const initCampaign = {
  recruit_start_time: moment().add(2, "hours").format("YYYY-MM-DD HH:mm"),
  recruit_end_time: moment().add(1, "days").format("YYYY-MM-DD HH:mm"),
  start_time: moment().add(3, "days").format("YYYY-MM-DD HH:mm"),
  deadline: moment().add(4, "days").format("YYYY-MM-DD HH:mm"),
  budget: 1000,
  per_action_budget: 1000,
  recruit_person_count: 1,
  hide_brand_name: false,
  sub_type: null,
  url: "",
  region: "全部",
  tags: "全部",
  age: '全部',
  gender: '全部',
  sns_platforms: "全部"
}

function initCampaignFun(state){
  const copy_campaign_id = getUrlQueryParams()['copy_id'];
  if (!!copy_campaign_id){
    return state.campaignReducer.get("campaign").toJSON()
  }else{
    return initCampaign
  }
}

const validate = new CampaignFormValidate({
  name: { require: true },
  description: { require: true },
  img_url: { require_img: true },
  budget: { require: true},
  per_action_budget: { require: true },
  action_url: {url: { require_protocol: false }},
  short_url: {url: { require_protocol: true }},
  url: {url: { require_protocol: false }}
})

const validateFailed = (errors) => {
  console.log(errors);
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
  if ( (Object.keys(errors).length === 1) && errors["img_url"]) {
    $("html,body").animate({scrollTop: $(".cover-photo").offset().top}, 100);
  }
}

function select(state){
  return { brand: state.profileReducer.get("brand")};
}

class CreateRecruitCampaign extends React.Component{
  constructor(props, context){
    super(props, context);
    _.bindAll(this, ["renderMaterialsPartial"]);
  }

  componentDidMount() {
    initToolTip({placement:'bottom', html: true});
    const copy_campaign_id = getUrlQueryParams()['copy_id'];
    if (!!copy_campaign_id){
      this._fetchCampaign(copy_campaign_id)
    }
  }

  _fetchCampaign(copy_campaign_id) {
    const { fetchCampaign } = this.props.actions;
    fetchCampaign(copy_campaign_id);
  }

  renderMaterialsPartial() {
    const {  materials, material_ids, sub_type } = this.props.fields;

    if (!sub_type.value) {
      return <CreateMaterialsPartial {...{materials, material_ids}} />
    }
  }

  render(){
    const { name, description, img_url, start_time, deadline,
          recruit_start_time, recruit_end_time, budget, per_action_budget,
          recruit_person_count, age, gender, tags, region, sns_platforms,
          hide_brand_name, materials, material_ids, url, sub_type
        } = this.props.fields;
    const { handleSubmit, submitting, invalid } = this.props;
    const { saveRecruit } = this.props.actions;

    return(
      <div className="page page-recruit page-recruit-new">
        <div className="container">
          <BreadCrumb />
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(saveRecruit)(event).catch(validateFailed) }}>
              <IntroPartial {...{name, description, img_url, hide_brand_name}}/>
              <SubTypePartial {...{url, sub_type}}/>
              { this.renderMaterialsPartial() }
              <RecruitDatePartial {...{ recruit_start_time, recruit_end_time }} />
              <DatePartial {...{ start_time, deadline }} />
              <RecruitBudgetPartial {...{budget, per_action_budget, recruit_person_count}} />
              <RecruitTargetPartial {...{age, gender, region, tags, sns_platforms}} />
              <div className="creat-form-footer">
                <p className="help-block">活动一旦通过审核将不能更改，我们将在2小时内审核当天18:00前提交的订单，其余时间段提交的订单次日审核</p>
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

CreateRecruitCampaign = reduxForm({
  form: "recruit_campaign_form",
  fields: ["name", "description", "img_url", "url", "start_time",
         "deadline", "recruit_start_time", "recruit_end_time", "budget", "per_action_budget",
         "recruit_person_count", "age", "gender", "tags", "region", "sns_platforms", "hide_brand_name", "materials", "material_ids", "sub_type"],
  returnRejectedSubmitPromise: true,
  validate
},
  state => ({
    initialValues: initCampaignFun(state)
  })
)(CreateRecruitCampaign);

export default connect(select)(CreateRecruitCampaign);
