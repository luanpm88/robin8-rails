import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import  _ from 'lodash';
import moment from 'moment';

import "campaign/recruit/form.scss";

import BreadCrumb            from './shared/BreadCrumb';
import IntroPartial          from "./recruit_campaigns/form/IntroPartial";
import CreateMaterialsPartial  from './shared/campaign_material/CreateMaterialsPartial'
import DatePartial           from './recruit_campaigns/form/OfflineDate';
import RecruitDatePartial    from './recruit_campaigns/form/RecruitDatePartial';
import RecruitBudgetPartial  from './recruit_campaigns/form/RecruitBudgetPartial';
import initToolTip           from './shared/InitToolTip';
import CampaignFormValidate  from './shared/validate/CampaignFormValidate'


const initCampaign = {
  recruit_start_time: moment().add(2, "hours").format("YYYY-MM-DD HH:mm"),
  recruit_end_time: moment().add(1, "days").format("YYYY-MM-DD HH:mm"),
  start_time: moment().add(3, "days").format("YYYY-MM-DD HH:mm"),
  deadline: moment().add(4, "days").format("YYYY-MM-DD HH:mm"),
  budget: 1000,
  per_action_budget: 1000,
  region: "全部",
  address: "",
  recruit_person_count: 1,
  hide_brand_name: false,
  influence_score: "gt_400"
}

const validate = new CampaignFormValidate({
  name: { require: true },
  description: { require: true },
  // img_url: { require_img: true },
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
  return { brand: state.profileReducer.get("brand")};
}

class CreateRecruitCampaign extends React.Component{
  constructor(props, context){
    super(props, context);
  }

  componentDidMount() {
    initToolTip({placement:'bottom', html: true});
  }

  render(){
    const { name, description, img_url, influence_score, start_time, deadline,
          recruit_start_time, recruit_end_time, budget, per_action_budget,
          recruit_person_count, task_description, address, region,
          hide_brand_name, materials, material_ids
        } = this.props.fields;
    const { handleSubmit, submitting, invalid } = this.props;
    const { saveRecruit } = this.props.actions;
    return(
      <div className="page page-recruit page-recruit-new">
        <div className="container">
          <BreadCrumb />
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(saveRecruit)(event).catch(validateFailed) }}>
              <IntroPartial {...{name, description, img_url, task_description, address, hide_brand_name}}/>
              {/* <RecruitTargetPartial {...{influence_score, region}}/> */}
              {<CreateMaterialsPartial {...{materials, material_ids}} />}
              <RecruitDatePartial {...{ recruit_start_time, recruit_end_time }} />
              <DatePartial {...{ start_time, deadline }} />
              <RecruitBudgetPartial {...{budget, per_action_budget, recruit_person_count}} />
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
  fields: ["name", "description", "img_url", "url", "influence_score", "start_time",
         "deadline", "recruit_start_time", "recruit_end_time", "budget", "per_action_budget",
         "recruit_person_count", "task_description", 'address', "region", "hide_brand_name", "materials", "material_ids"],
  returnRejectedSubmitPromise: true,
  validate
},
  state => ({
    initialValues: initCampaign
  })
)(CreateRecruitCampaign);

export default connect(select)(CreateRecruitCampaign);
