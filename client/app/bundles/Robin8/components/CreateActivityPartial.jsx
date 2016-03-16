import React from 'react'
import { reduxForm } from 'redux-form'
import { connect } from 'react-redux'

import "create_activity.css"

import IntroPartial from './create_activity/IntroPartial'
import TargetPartial from './create_activity/TargetPartial'
import DetailPartial from './create_activity/DetailPartial'
import DatePartial from './create_activity/DatePartial'
import BudgetPartial from './create_activity/BudgetPartial'

import createActivity from "raw/create_activity"


function select(state) {
  return { brand_id: state.$$brandHomeStore.get("brand").get("id") };
}


class CreateActivityPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
  }

  componentDidMount() {
    createActivity()
  }

  render() {
    const { name, description, image, url, age, province, city, sex, message, budget, per_budget_type, action_url, action_url_identifier, short_url, start_time, per_action_budget, deadline } = this.props.fields;
    const brand_id = this.props.brand_id

    return (
      <div className="wrapper">
        <div className="container">
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={this.props.handleSubmit(this.props.actions.saveCampaign)}>
              <IntroPartial {...{ name, description, image, url }}/>
              <TargetPartial {...{ age, province, city, sex, message }} />
              <BudgetPartial {...{ budget }} />
              <DetailPartial {...{ per_budget_type, action_url_identifier, action_url, short_url, per_action_budget, brand_id }} />
              <DatePartial {...{ start_time, deadline }} />

              <div className="creat-form-footer">
                <p className="help-block">以上信息将帮助Robin8精确计算合适的推广渠道，请谨慎填写</p>
                <button type="submit" className="btn btn-blue btn-lg">完成发布活动并查看相关公众号</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    )
  }
}

CreateActivityPartial = reduxForm({
  form: 'activity_form',
  fields: ['name', 'description', 'image', 'url', 'age', 'province', 'city', 'sex', 'message', 'budget', 'per_budget_type', 'action_url', 'action_url_identifier' ,'short_url', 'start_time', 'per_action_budget', 'deadline']
})(CreateActivityPartial);

export default connect(select)(CreateActivityPartial)
