import React, { PropTypes } from 'react'
import { Link } from 'react-router'
import Campaign from './Campaign'
import showPaginate from 'raw/campaign-list'
import getUrlQueryParams from '../../helpers/GetUrlQueryParams'

export default class CampaignList extends React.Component {

  constructor(props, context) {
    super(props, context)
    this.displayPaginator = this.displayPaginator.bind(this)
  }

  componentDidMount() {
    const { fetchCampaigns } = this.props.actions;

    const page_params = getUrlQueryParams()["page"]
    const currentPage = page_params ? page_params : 1
    fetchCampaigns({ page:  currentPage});
  }

  componentDidUpdate() {
    this.displayPaginator(this.props)
  }

  displayPaginator(props) {
    const { fetchCampaigns } = this.props.actions;
    if (this.props.data.get("paginate").get("X-Page")) {
      const pagination_options = {
        currentPage: this.props.data.get("paginate").get("X-Page"),
        totalPages: this.props.data.get("paginate").get("X-Total-Pages"),
        size: 'large',
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
      showPaginate(pagination_options)
    }
  }

  render() {
    const actions = this.props.actions;
    const campaignList = this.props.data.get('campaignList');

    return (
      <div className="wrapper">
        <div className="container">
          <div className="panel my-activities-panel">
            <div className="panel-heading">
              <a href="#panelActivities" data-toggle="collapse" className="switch">
                <span className="txt">收起</span>
                <i className="caret-arrow"></i>
              </a>

              <Link to="/brand/create_activity" className="btn btn-blue btn-big quick-btn">
                添加推广活动
              </Link>

              <h4 className="panel-title">
                我的推广活动
                <span className="carte">/</span>
                <strong className="stat-num">
                  { this.props.data.get("paginate").get('X-Total') }
                </strong>
              </h4>
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
