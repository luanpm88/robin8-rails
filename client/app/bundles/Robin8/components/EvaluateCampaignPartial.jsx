import React, { Component } from 'react';
import { Link } from 'react-router';
import { reduxForm } from 'redux-form';
import moment from 'moment';
import { connect } from 'react-redux';
import _ from 'lodash'

import "campaign/activity/show.scss";
import "campaign/activity/form.scss";

import BreadCrumb               from './shared/BreadCrumb';
import Basic                    from './campaigns/show/Basic';
import Evaluate                 from './campaigns/form/EvaluatePartial.jsx';
import RevokeConfirmModal       from './campaigns/modals/RevokeConfirmModal';
import initToolTip              from './shared/InitToolTip';
import EvaluateCampaignFormValidate    from './shared/validate/EvaluateCampaignFormValidate'

import { canEditCampaign, canPayCampaign } from '../helpers/CampaignHelper'

function select(state){
  return {
    campaign: state.campaignReducer.get('campaign')
  };
}

const validate = new EvaluateCampaignFormValidate({
  review_content: { require: true },
  effect_score: { require: true },
})

const validateFailed = (errors) => {
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
}

class EvaluateCampaignPartial extends Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ['_fetchCampaign', '_evaluateCampaign']);
  }

  componentDidMount() {
    initToolTip({placement:'bottom', html: true});
    this._fetchCampaign();
  }

  componentWillUnmount() {
    this.props.actions.clearCampaign();
  }

  _evaluateCampaign() {
    const { evaluateCampaign } = this.props.actions;
    const campaign_id = this.props.params.id;
    const campaign_fields = this.props.values;
    evaluateCampaign(campaign_id, campaign_fields);
  }

  _fetchCampaign() {
    const campaign_id = this.props.params.id;
    const { fetchCampaign } = this.props.actions;
  }


  render() {
    const {campaign, actions} = this.props;
    const campaign_id = this.props.params.id
    const { review_content, evaluation_status, effect_score } = this.props.fields;
    const { handleSubmit, submitting, invalid } = this.props;
    const { saveCampaign } = this.props.actions;

    return (
    <div className="page page-activity page-activity-new">
      <div className="container">
        <BreadCrumb />
        <div className="creat-activity-wrap">
          <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(this._evaluateCampaign)(event).catch(validateFailed) } }>
            <Basic {...{campaign}} />
            <Evaluate {...{ review_content, effect_score }}/>
            <div className="creat-form-footer">
              <p className="help-block">活动一旦评价将不能修改</p>
              <button type="submit" className="btn btn-blue btn-lg createCampaignSubmit" disabled={ submitting }>完成评价</button>
            </div>
          </form>
        </div>
        <div id="sublist"></div>
      </div>
    </div>
    );
  }
}

EvaluateCampaignPartial = reduxForm(
  {
    form: 'activity_form',
    fields: [ 'review_content', 'evaluation_status', 'effect_score'],
    returnRejectedSubmitPromise: true,
    validate
  },
  state => (
  {
    initialValues: state.campaignReducer.get("campaign").toJSON()
  })
)(EvaluateCampaignPartial);

export default connect(select)(EvaluateCampaignPartial)
