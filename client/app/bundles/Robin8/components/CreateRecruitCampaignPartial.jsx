import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { _ } from 'lodash';
import moment from 'moment';

import "create_recruit.scss";

import IntroPartial from "./create_campaign/IntroPartial";
import RecruitTargetPartial from './create_recruit/RecruitTargetPartial';
import DatePartial from './create_campaign/DatePartial';
import RecruitDatePartial from './create_recruit/RecruitDatePartial';

const initCampaign = {
  recruit_start_time: moment().add(2, "hours").format("YYYY-MM-DD HH:mm"),
  recruit_end_time: moment().add(2, "days").format("YYYY-MM-DD HH:mm"),
  start_time: moment().add(2, "hours").format("YYYY-MM-DD HH:mm"),
  deadline: moment().add(2, "days").format("YYYY-MM-DD HH:mm")
}

const validate = new FormValidate({
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

  render(){
    const { name, description, img_url, url, influence_score, start_time, deadline, recruit_start_time, recruit_end_time} = this.props.fields;
    const { handleSubmit, submitting, invalid } = this.props;
    const { saveCampaign } = this.props.actions;
    return(
      <div className="wrapper">
        <div className="container">
          {this.render_breadcrumb()}
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(saveCampaign)(event).catch(validateFailed) }}>
              <IntroPartial {...{name, description, img_url, url, }}/>
              <RecruitTargetPartial {...{influence_score}}/>
              <RecruitDatePartial {...{ recruit_start_time, recruit_end_time }} />
              <DatePartial {...{ start_time, deadline }} />
              <RecruitBudgetPartial {...{}} />
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
  fields: ["name", "description", "img_url", "url", "influence_score", "start_time", "deadline", "recruit_start_time", "recruit_end_time"],
  returnRejectedSubmitPromise: true,
  validate
},
  state => ({
    initialValues: initCampaign
  })
)(CreateRecruitCampaign);

export default connect(select)(CreateRecruitCampaign);