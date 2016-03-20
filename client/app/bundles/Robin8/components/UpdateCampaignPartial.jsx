import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';

import "create_activity.css";

import IntroPartial from './create_campaign/IntroPartial';
import TargetPartial from './create_campaign/TargetPartial';
import DetailPartial from './create_campaign/DetailPartial';
import DatePartial from './create_campaign/DatePartial';
import BudgetPartial from './create_campaign/BudgetPartial';
import createActivity from "raw/create_campaign";

const validate = new FormValidate({
  name: { require: true },
  description: { require: true },
  url: { require: true, url: { require_protocol: true} },
  message: { require: true }
})

const validateFailed = (errors) => {
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
}

function select(state) {
  return {
    brand: state.$$brandStore.get("brand")
  };
}

class UpdateCampaignPartial extends React.Component {
  constructor(props, context) {
    super(props, context);
  }

  componentDidMount() {
    createActivity()
    const campaign_id = this.props.params.id
    const { fetchCampaign } = this.props.actions
    fetchCampaign(campaign_id)
  }

  render() {
    const { name, description, image, url, age, province, city, gender, message, budget, per_budget_type, action_url, action_url_identifier, short_url, start_time, per_action_budget, deadline } = this.props.fields;
    const brand = this.props.brand
    const { handleSubmit, submitting, invalid } = this.props;
    const { saveCampaign } = this.props.actions;

    return (
      <div className="wrapper">
        <div className="container">
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(saveCampaign)(event).catch(validateFailed) } }>
              <IntroPartial {...{ name, description, image, url }}/>
              <TargetPartial {...{ age, province, city, gender, message }} />
              <BudgetPartial {...{ budget }} />
              <DetailPartial {...{ per_budget_type, action_url_identifier, action_url, short_url, per_action_budget, brand }} />
              <DatePartial {...{ start_time, deadline }} />

              <div className="creat-form-footer">
                <p className="help-block">以上信息将帮助Robin8精确计算合适的推广渠道，请谨慎填写</p>
                <button type="submit" className="btn btn-blue btn-lg" disabled={ submitting }>完成发布活动并查看相关公众号</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    )
  }
}

UpdateCampaignPartial = reduxForm({
  form: 'activity_form',
  fields: ['name', 'description', 'image', 'url', 'age', 'province', 'city', 'gender', 'message', 'budget', 'per_budget_type', 'action_url', 'action_url_identifier' ,'short_url', 'start_time', 'per_action_budget', 'deadline'],
  returnRejectedSubmitPromise: true,
  validate
},
state => ({
  initialValues: state.$$brandStore.get("campaign").toJSON()
})
)(UpdateCampaignPartial);

export default connect(select)(UpdateCampaignPartial)
