import React, { PropTypes } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';

import Campaign from './Campaign';
import getUrlQueryParams from '../../helpers/GetUrlQueryParams';


function select(state) {
  return { CampaignData: state.campaignReducer };
}

class CampaignList extends React.Component {

  constructor(props, context) {
    super(props, context)
    this.displayPaginator = this.displayPaginator.bind(this)
  }

  componentDidMount() {
    const { fetchCampaigns, fetchBrandProfile } = this.props.actions;

    const page_params = getUrlQueryParams()["page"]
    const currentPage = page_params ? page_params : 1
    fetchCampaigns({ page:  currentPage});
    fetchBrandProfile();
  }

  componentDidUpdate() {
    this.displayPaginator(this.props)
  }

  displayPaginator(props) {
    const { fetchCampaigns } = this.props.actions;
    if (this.props.CampaignData.get("paginate").get("X-Page")) {
      let totalPage = this.props.CampaignData.get("paginate").get("X-Total-Pages")

      const pagination_options = {
        currentPage: this.props.CampaignData.get("paginate").get("X-Page"),
        totalPages: totalPage,
        shouldShowPage: function(type, page, current) {
          switch (type) {
            default:
              return true
          }
        },
        onPageClicked:  function(e,originalEvent,type,page){
          fetchCampaigns({ page: page });
        }
      }
      $("#campaigns-paginator").bootstrapPaginator(pagination_options);
    }
  }

  renderNewCampaignButton() {
    return (
      <div className="btn-group quick-btn-group ">
        <Link to="/brand/campaigns/select" className="btn btn-blue quick-btn">
          添加活动
        </Link>
      </div>
    );
  }

  render() {
    const actions = this.props.actions;
    const campaignList = this.props.CampaignData.get('campaignList');
    const campaignCount = this.props.CampaignData.get("paginate").get('X-Total')
    const avail_amount = this.props.profileData.get("brand").get("avail_amount")
    return (
      <div className="wrapper">
        <div className="container">
          <div className="panel brand-activities">
            <div className="panel-heading clearfix">
              <a href="#panelActivities" data-toggle="collapse" className="switch">
                <span className="txt">收起</span>
                <i className="caret-arrow"></i>
              </a>

              { this.renderNewCampaignButton() }

              {/*<h4 className="panel-title">
                我的推广活动
                <span className="slash">/</span>
                <strong className="stat-num">
                  { campaignCount }
                </strong>
                <span className="balance">当前余额</span>
                  <strong className="stat-num">
                    &nbsp;&nbsp;
                    <span className="money">￥</span>
                    <span className="avail-amount">{avail_amount}</span>
                  </strong>
                <Link to="/brand/financial/recharge" className="btn btn-blue btn-default recharge-btn">
                  充值
                </Link>
              </h4>*/}
            </div>

            <div id="panelActivities" className="panel-collapse collapse in">
              <div className="panel-body">

                { do
                  {
                    campaignList.map(function(campaign, index){
                      if (index % 2 === 0) {
                        return <Campaign campaign= {campaign} tagColor="brand-activity-card" key={ index } />
                      } else {
                        return <Campaign campaign= {campaign} tagColor="brand-activity-card closure" key={ index } />
                      }
                    })
                  }
                }

                <div id="campaigns-paginator">
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default connect(select)(CampaignList)
