import React from 'react'
import { reduxForm } from 'redux-form'

import "create_activity.css"

import IntroPartial from './create_activity/IntroPartial'
import TargetPartial from './create_activity/TargetPartial'
import ContentPartial from './create_activity/ContentPartial'
import DatePartial from './create_activity/DatePartial'
import BudgetPartial from './create_activity/BudgetPartial'

import createActivity from "raw/create_activity"

class CreateActivityPartial extends React.Component {

  componentDidMount() {
    createActivity()
  }

  render() {
    const {name, description, image, start_time, deadline, forward_url, content, url, originality, budget} = this.props.fields;

    return (
      <div className="wrapper">
        <div className="container">
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={this.props.handleSubmit(this.props.actions.saveCampaign)}>
              <IntroPartial {...{name, description, image}}/>
              <TargetPartial />
              <BudgetPartial {...{budget}} />
              <ContentPartial {...{forward_url, content, url, originality}} />
              <DatePartial {...{start_time, deadline}} />

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
  fields: ['name', 'description', 'image', 'start_time', 'deadline', 'forward_url', 'content', 'url', 'originality', 'budget']
})(CreateActivityPartial);

export default CreateActivityPartial
