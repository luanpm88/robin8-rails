import React from 'react'
import { reduxForm } from 'redux-form'

import "create_activity.css"

import createActivity from "raw/create_activity"

import IntroPartial from './create_activity/IntroPartial'
import ContentPartial from './create_activity/ContentPartial'
import DatePartial from './create_activity/DatePartial'
import BudgetPartial from './create_activity/BudgetPartial'

export default class CreateActivityPartial extends React.Component {

  componentDidMount() {
    createActivity()
  }

  render() {

    return (
      <div className="wrapper">
        <div className="container">
          <div className="creat-activity-wrap">
            <form action="" name="" id="">
              <IntroPartial />
              <ContentPartial />
              <DatePartial />
              <BudgetPartial />

              <div className="creat-form-footer">
                <p className="help-block">以上信息将帮助Robin8精确计算合适的推广渠道，请谨慎填写。在此<a href="#">预览</a></p>
                <button type="submit" className="btn btn-blue btn-lg">查看最优推广渠道</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    )
  }
}
