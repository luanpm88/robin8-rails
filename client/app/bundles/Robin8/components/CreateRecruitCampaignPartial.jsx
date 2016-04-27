import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import  _ from 'lodash';
import moment from 'moment';

import "create_recruit.scss";

import IntroPartial from "./create_recruit/IntroPartial";
import RecruitTargetPartial from './create_recruit/RecruitTargetPartial';
import DatePartial from './create_recruit/OfflineDate';
import RecruitDatePartial from './create_recruit/RecruitDatePartial';
import RecruitBudgetPartial from './create_recruit/RecruitBudgetPartial';
import initToolTip from './shared/InitToolTip';

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

class CreateRecruitCampaign extends React.Component{
  constructor(props, context){
    super(props, context);
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

  componentDidMount() {
    initToolTip({placement:'bottom', html: true});  
  }

  render(){
    const { name, description, img_url, influence_score, start_time, deadline, 
          recruit_start_time, recruit_end_time, budget, per_action_budget, 
          recruit_person_count, task_description, address, region,
          hide_brand_name
        } = this.props.fields;
    const { handleSubmit, submitting, invalid } = this.props;
    const { saveRecruit } = this.props.actions;
    return(
      <div className="wrapper">
        <div className="container">
          {this.render_breadcrumb()}
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(saveRecruit)(event).catch(validateFailed) }}>
              <IntroPartial {...{name, description, img_url, task_description, address, hide_brand_name}}/>
              <RecruitTargetPartial {...{influence_score, region}}/>
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
         "deadline", "recruit_start_time", "recruit_end_time", "budget", "per_action_budget", "recruit_person_count", "task_description", 'address', "region", "hide_brand_name"],
  returnRejectedSubmitPromise: true,
  validate
},
  state => ({
    initialValues: initCampaign
  })
)(CreateRecruitCampaign);

export default connect(select)(CreateRecruitCampaign);