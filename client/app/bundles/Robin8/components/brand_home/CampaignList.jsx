import React, { PropTypes } from 'react'
import Campaign from './Campaign'
import showPaginate from 'raw/campaign-list'
import getUrlQueryParams from '../../helpers/GetUrlQueryParams'

export default class CampaignList extends React.Component {
  static propTypes = {
    actions: PropTypes.object.isRequired,
    data: PropTypes.object.isRequired
  }

  constructor(props, context) {
    super(props, context)
  }

  componentDidMount() {
    const { fetchCampaigns } = this.props.actions;

    let page_params = getUrlQueryParams()["page"]
    let currentPage = page_params ? page_params : 1
    fetchCampaigns({ page:  currentPage});
  }

  componentDidUpdate() {
    const { fetchCampaigns } = this.props.actions;
    if (this.props.data.get("currentPage")) {
      let pagination_options = {
        currentPage: this.props.data.get("currentPage"),
        totalPages: this.props.data.get("totalPages"),
        size: 'large',
        onPageClicked:  function(e,originalEvent,type,page){
          fetchCampaigns({ page: page });
        }
      }
      showPaginate(pagination_options)
    }
  }

  render() {
    const actions = this.props.actions;
    const campaignList = this.props.data.get('campaignList');

    var campaigns = [];

    for (var index = 0; index < campaignList.size; index++) {
      if (index % 2 === 0) {
        campaigns.push( <Campaign campaign= {campaignList.get(index)} tagColor="brand-activity-card" key={ index } /> );
      }
      else {
        campaigns.push( <Campaign campaign= {campaignList.get(index)} tagColor="brand-activity-card closure"key={ index } /> );
      }
    }

    return (
      <div className="wrapper">
        <div className="container">
          <div className="panel my-activities-panel">
            <div className="panel-heading">
              <a href="#panelActivities" data-toggle="collapse" className="switch">
                <span className="txt">收起</span>
                <i className="caret-arrow"></i>
              </a>

              <a href="#" className="btn btn-blue btn-big quick-btn">
                添加推广活动
              </a>

              <h4 className="panel-title">
                我的推广活动
                <span className="carte">/</span>
                <strong className="stat-num">
                  { this.props.data.get('campaignsCount') }
                </strong>
              </h4>
            </div>

            <div id="panelActivities" className="panel-collapse collapse in">
              <div className="panel-body">
                {campaigns}
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
