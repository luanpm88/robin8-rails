import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import _ from 'lodash';
import moment from 'moment';

import "campaign/activity/form.scss";

import IntroPartial   from './campaigns/form/IntroPartial';
import TargetPartial  from './campaigns/form/TargetPartial';
import DetailPartial  from './campaigns/form/DetailPartial';
import DatePartial    from './campaigns/form/DatePartial';
import BudgetPartial  from './campaigns/form/BudgetPartial';
import beforeUnload   from './shared/BeforeUnload';
import initToolTip    from './shared/InitToolTip';

const initCampaign = {
  age: 'all',
  province: '全部',
  city: '全部',
  gender: 'all',
  message: '',
  budget: 100,
  per_budget_type: 'post',
  per_action_budget: 2,
  start_time: moment().add(2, 'hours').format('YYYY-MM-DD HH:mm'),
  deadline: moment().add(2, 'days').format('YYYY-MM-DD HH:mm')
}

const validate = new FormValidate({
  name: { require: true },
  description: { require: true },
  url: { require: true, url: { require_protocol: true } },
  img_url: { require_img: true },
  budget: { require: true, min_budget: 100 },
  per_action_budget: { require: true },
  action_url: {url: { require_protocol: true }},
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
  return { brand: state.$$brandStore.get("brand") };
}

class CreateCampaignPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
  }

  componentDidMount() {
    beforeUnload(this.props);
    initToolTip({placement:'bottom', html: true});
  }

  render_breadcrumb() {
    return (
      <ol className="breadcrumb">
        <li>
          <i className="caret-arrow left" />
          <Link to="/brand/">我的主页</Link>
        </li>
      </ol>
    );
  }

  render() {
    const { name, description, img_url, url, age, province, city, gender, message, budget, per_budget_type, action_url, action_url_identifier, short_url, start_time, per_action_budget, deadline } = this.props.fields;
    const brand = this.props.brand
    const { handleSubmit, submitting, invalid } = this.props;
    const { saveCampaign } = this.props.actions;

    return (
      <div className="page page-activity page-activity-new">
        <div className="container">
         { this.render_breadcrumb() }
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(saveCampaign)(event).catch(validateFailed) } }>
              <IntroPartial {...{ name, description, img_url, url }}/>
              <BudgetPartial {...{ budget }} />
              <DetailPartial {...{ per_budget_type, action_url_identifier, action_url, short_url, per_action_budget, brand }} />
              <DatePartial {...{ start_time, deadline }} />

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
  fields: ['name', 'description', 'img_url', 'url', 'age', 'province', 'city', 'gender', 'message', 'budget', 'per_budget_type', 'action_url', 'action_url_identifier' ,'short_url', 'start_time', 'per_action_budget', 'deadline'],
  returnRejectedSubmitPromise: true,
  validate
},
state => ({
  initialValues: initCampaign
})
)(CreateCampaignPartial);

export default connect(select)(CreateCampaignPartial)
