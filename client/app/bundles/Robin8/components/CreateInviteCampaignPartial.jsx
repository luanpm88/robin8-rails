import React from 'react';
import { reduxForm } from 'redux-form';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import  _ from 'lodash';
import moment from 'moment';

import "campaign/invite/form.scss";

import BreadCrumb            from './shared/BreadCrumb';
import IntroPartial          from "./invite_campaigns/form/IntroPartial";
import DatePartial           from './invite_campaigns/form/OfflineDate';
import KolSelectPartial      from './invite_campaigns/form/KolSelectPartial';
import initToolTip           from './shared/InitToolTip';
import CampaignFormValidate  from './shared/validate/CampaignFormValidate'
import CreateMaterialsPartial  from './shared/campaign_material/CreateMaterialsPartial'

const initCampaign = {
  start_time: moment().add(3, "days").format("YYYY-MM-DD HH:mm"),
  deadline: moment().add(10, "days").format("YYYY-MM-DD HH:mm"),
  budget: 0,
  social_accounts: []
}

const validate = new CampaignFormValidate({
  name: { require: true },
  description: { require: true },
  img_url: { require_img: true },
  budget: { require: false }
})

const validateFailed = (errors) => {
  console.log(errors);
  $('[name="' + Object.keys(errors)[0] + '"]').focus();
  if ( (Object.keys(errors).length === 1) && errors["img_url"]) {
    $("html,body").animate({scrollTop: $(".cover-photo").offset().top}, 100);
  }
}

function select(state){
  return {
    brand: state.profileReducer.get("brand")
  };
}

class CreateInviteCampaign extends React.Component{
  constructor(props, context){
    super(props, context);
  }

  componentDidMount() {
    initToolTip({placement:'bottom', html: true});
  }

  render(){
    const { name, description, img_url, start_time, deadline,
            budget, social_accounts, materials, material_ids
          } = this.props.fields;

    const { handleSubmit, submitting, invalid } = this.props;
    const { saveInvite } = this.props.actions;

    return(
      <div className="page page-invite page-invite-new">
        <div className="container">
          <BreadCrumb />
          <div className="creat-activity-wrap">
            <form action="" name="" id="" onSubmit={ (event) => { handleSubmit(saveInvite)(event).catch(validateFailed) }}>
              <IntroPartial {...{name, description, img_url}}/>
              <CreateMaterialsPartial {...{materials, material_ids}} />
              <DatePartial {...{ start_time, deadline }} />
              <KolSelectPartial {...{ budget, social_accounts }} />
              <div className="creat-form-footer">
                <p className="help-block">活动一旦通过审核将不能更改，我们将在2小时内审核当天18:00前提交的订单，其余时间段提交的订单次日审核</p>
                <button
                  type="submit"
                  className="btn btn-blue btn-lg createCampaignSubmit"
                  disabled={ submitting }>
                  确认创建活动
                </button>
              </div>
            </form>
          </div>
          <div id="sublist"></div>
        </div>
      </div>
    )
  }
}

CreateInviteCampaign = reduxForm({
  form: "invite_campaign_form",
  fields: ["name", "description", "img_url", "start_time", "deadline",
           "materials", "material_ids", "budget", "social_accounts"],
  returnRejectedSubmitPromise: true,
  validate
},
  state => ({
    initialValues: initCampaign
  })
)(CreateInviteCampaign);

export default connect(select)(CreateInviteCampaign);
