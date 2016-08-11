import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import _ from 'lodash';
import moment from 'moment';

import "campaign/activity/form.scss";

import BreadCrumb     from './shared/BreadCrumb';
import IntroPartial   from './campaigns/form/IntroPartial';
import TargetPartial  from './campaigns/form/TargetPartial';
import DetailPartial  from './campaigns/form/DetailPartial';
import DatePartial    from './campaigns/form/DatePartial';
import BudgetPartial  from './campaigns/form/BudgetPartial';
import beforeUnload   from './shared/BeforeUnload';
import initToolTip    from './shared/InitToolTip';
import CampaignFormValidate from './shared/validate/CampaignFormValidate'

const initCampaign = {
  age: 'all',
  region: '全部',
  tags: "全部",
  gender: 'all',
  message: '',
  budget: 100,
  per_budget_type: 'click',
  per_action_budget: 0.2,
  start_time: moment().add(2, 'hours').format('YYYY-MM-DD HH:mm'),
  deadline: moment().add(2, 'days').format('YYYY-MM-DD HH:mm'),
  per_budget_collect_type: ""
}

const validate = new CampaignFormValidate({
  name: { require: true },
  description: { require: true },
  url: { require: true, url: { require_protocol: false } },
  // img_url: { require_img: true },
  budget: { require: true, min_budget: 100 },
  per_action_budget: { require: true },
  action_url: {url: { require_protocol: false }},
  short_url: {url: { require_protocol: true }},
})

const validateFailed = (errors) => {
  console.log(errors);
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
  if ( (Object.keys(errors).length === 1) && errors["img_url"]) {
    $("html,body").animate({scrollTop: $(".cover-photo").offset().top}, 100);
  }
}

function select(state) {
  return { brand: state.profileReducer.get("brand") };
}

class CreateCampaignPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
  }

  componentDidMount() {
    beforeUnload(this.props);
    initToolTip({placement:'bottom', html: true});
  }

  render() {
    const { name, description, img_url, url, age, gender, region, tags, message, budget, per_budget_type, action_url, action_url_identifier, short_url, start_time, per_action_budget, deadline, per_budget_collect_type} = this.props.fields;
    const brand = this.props.brand
    const { handleSubmit, submitting, invalid } = this.props;
    const { saveCampaign } = this.props.actions;

    return (
      <div className="page page-activity page-activity-new">
        <div className="container">
         <BreadCrumb />
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(saveCampaign)(event).catch(validateFailed) } }>
              <IntroPartial {...{ name, description, img_url, url }}/>
              <BudgetPartial {...{ budget }} />
              <DetailPartial {...{ per_budget_type, action_url_identifier, action_url, short_url, per_action_budget, brand, per_budget_collect_type }} />
              <DatePartial {...{ start_time, deadline }} />
              <TargetPartial {...{region, tags}} />
              <div className="creat-form-footer">
                <p className="help-block">活动一旦通过审核将不能更改，我们将在2小时内审核当天18:00前提交的订单，其余时间段提交的订单次日审核</p>
                <button type="submit" className="btn btn-blue btn-lg createCampaignSubmit" disabled={ submitting }>完成发布活动</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    )
  }
}

CreateCampaignPartial = reduxForm({
  form: 'activity_form',
  fields: ['name', 'description', 'img_url', 'url', 'age', 'region', 'tags', 'gender', 'message', 'budget', 'per_budget_type', 'action_url', 'action_url_identifier' ,'short_url', 'start_time', 'per_action_budget', 'deadline', 'per_budget_collect_type'],
  returnRejectedSubmitPromise: true,
  validate
},
state => ({
  initialValues: initCampaign
})
)(CreateCampaignPartial);

export default connect(select)(CreateCampaignPartial)
