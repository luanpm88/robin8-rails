import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import _ from 'lodash'
import NotificationSystem from "react-notification-system";

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
  url: { require: true, url: { require_protocol: true } },
  img_url: { require_img: true },
  budget: { require: true, min_budget: 100 },
  per_action_budget: { require: true },
  action_url: {url: { require_protocol: true }},
  short_url: {url: { require_protocol: true }}
})

const validateFailed = (errors) => {
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
  if ( (Object.keys(errors).length === 1) && errors["img_url"]) {
    $("html,body").animate({scrollTop: $(".cover-photo").offset().top}, 100);
  }
}

function select(state) {
  return {
    brand: state.$$brandStore.get("brand")
  };
}

class UpdateCampaignPartial extends React.Component {
  _notificationSystem: null

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_fetchCampaign', '_updateCampaign']);
  }

  _fetchCampaign() {
    const campaign_id = this.props.params.id;
    const { fetchCampaign } = this.props.actions;
    fetchCampaign(campaign_id);
  }

  _updateCampaign() {
    const { updateCampaign } = this.props.actions;
    const campaign_id = this.props.data.get("campaign").get("id");
    const campaign_fields = this.props.values;
    const notification = {
      title: 'I\'ll be here forever!',
      message: 'Just kidding, you can click me.',
      level: 'success',
      position: 'tr',
      autoDismiss: 1
    }
    this._notificationSystem.addNotification(notification)
    updateCampaign(campaign_id, campaign_fields);
  }

  componentDidMount() {
    createActivity();
    this._fetchCampaign();
    this._notificationSystem = this.refs.notificationSystem;
  }

  render() {
    console.log('-----------');
    console.log(this.props);
    const { name, description, img_url, url, age, province, city, gender, message, budget, per_budget_type, action_url, action_url_identifier, short_url, start_time, per_action_budget, deadline } = this.props.fields;
    const brand = this.props.brand;
    const { handleSubmit, submitting, invalid } = this.props;
    const { updateCampaign } = this.props.actions;

    return (
      <div className="wrapper">
        <div className="container">
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(this._updateCampaign)(event).catch(validateFailed) } }>
              <IntroPartial {...{ name, description, img_url, url }}/>
              <BudgetPartial {...{ budget }} />
              <DetailPartial {...{ per_budget_type, action_url_identifier, action_url, short_url, per_action_budget, brand }} />
              <DatePartial {...{ start_time, deadline }} />

              <div className="creat-form-footer">
                <div className="alert alert-danger alert-dismissible fade in" role="alert">
                  <button type="button" className="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">×</span>
                  </button>
                  <strong>Holy guacamole!</strong>Best check yo self, you are not looking too good.
                </div>
                <p className="help-block">以上信息将帮助Robin8精确计算合适的推广渠道，请谨慎填写</p>
                <NotificationSystem ref="notificationSystem" allHTML={false}/>
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
  fields: ['name', 'description', 'img_url', 'url', 'age', 'province', 'city', 'gender', 'message', 'budget', 'per_budget_type', 'action_url', 'action_url_identifier' ,'short_url', 'start_time', 'per_action_budget', 'deadline'],
  returnRejectedSubmitPromise: true,
  validate
},
state => ({
  initialValues: state.$$brandStore.get("campaign").toJSON()
})
)(UpdateCampaignPartial);

export default connect(select)(UpdateCampaignPartial)
