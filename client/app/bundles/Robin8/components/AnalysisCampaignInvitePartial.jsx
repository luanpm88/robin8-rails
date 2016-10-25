import React from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import moment from 'moment';
import _ from 'lodash';

import ReactEcharts from './shared/ReactEcharts';
import WordCloud from './shared/WordCloud';

import "campaign/analysis.scss";

function select(state) {
  return {
    brand: state.profileReducer.get("brand"),
    analysis_invite_result: state.campaignReducer.get("analysis_invite_result")
  }
}

class AnalysisCampaignInvitePartial extends React.Component {
  constructor(props, context) {
    super(props, context);
    _.bindAll(this, [
      "renderGenderChart",
      "renderAgeChart",
      "renderTagChart",
      "renderRegionChart"
    ])
  }

  componentDidMount() {
    const campaign_id = this.props.params.id;
    const { AnalysisInvitesOfCampaign } = this.props.actions;
    AnalysisInvitesOfCampaign(campaign_id);
  }

  componentWillUnmount() {
    // this.props.actions.clearAnalysisCampaignInvite();
  }

  renderGenderChart(data) {
    if (!data || data.length == 0) {
      return <div className="gender-chart chart-loading">
        数据加载中...
      </div>
    }

    let genders = data.toJS();

    genders = _.map(genders, (obj) => {
      return {
        name: obj["name"],
        value: obj["ratio"]
      }
    });

    let labels = _.map(genders, (obj) => {
      return obj["name"];
    });

    const option = {
      color: ['#f54750', '#4e5460', '#4dc0bd', '#fcb364', '#95a1b1'],
      tooltip: {
        trigger: 'item',
        formatter: "{a} <br/>{b}: {c} ({d}%)"
      },
      legend: {
        orient: 'vertical',
        x: 'right',
        top: 'middle',
        data: labels
      },
      series: [
        {
          name:'KOL性别分析',
          type:'pie',
          radius: ['30%', '70%'],
          avoidLabelOverlap: false,
          label: {
              normal: {
                  show: false,
                  position: 'center'
              },
              emphasis: {
                  show: true,
                  textStyle: {
                      fontSize: '18'
                  }
              }
          },
          labelLine: {
              normal: {
                  show: false
              }
          },
          data: genders
        }
      ]
    };

    return <div className="chart-wrapper gender-chart">
      <ReactEcharts height={360} option={option} showLoading={false}/>
    </div>
  }

  renderAgeChart(data) {
    if (!data || data.length == 0) {
      return <div className="age-chart chart-loading">
        数据加载中...
      </div>
    }

    let ages = data.toJS();

    ages = _.map(ages, (obj) => {
      return {
        name: obj["name"],
        value: obj["ratio"]
      }
    });

    let labels = _.map(ages, (obj) => {
      return obj["name"];
    });

    const option = {
      color: ['#f54750', '#4e5460', '#4dc0bd', '#fcb364', '#95a1b1'],
      tooltip: {
        trigger: 'item',
        formatter: "{a} <br/>{b}: {c} ({d}%)"
      },
      legend: {
        orient: 'vertical',
        x: 'right',
        top: 'middle',
        data: labels
      },
      series: [
        {
          name:'KOL年龄分析',
          type:'pie',
          radius: ['30%', '70%'],
          avoidLabelOverlap: false,
          label: {
              normal: {
                  show: false,
                  position: 'center'
              },
              emphasis: {
                  show: true,
                  textStyle: {
                      fontSize: '18'
                  }
              }
          },
          labelLine: {
              normal: {
                  show: false
              }
          },
          data: ages
        }
      ]
    };

    return <div className="chart-wrapper age-chart">
      <ReactEcharts height={360} option={option} showLoading={false}/>
    </div>
  }

  renderTagChart(data) {
    if (!data || data.length == 0) {
      return <div className="tag-chart chart-loading">
        数据加载中...
      </div>
    }

    let tags = data.toJS();

    tags = _.map(tags, (obj) => {
      return {
        name: obj["name"],
        value: obj["ratio"]
      }
    });

    let labels = _.map(tags, (obj) => {
      return obj["name"];
    });

    const option = {
      color: ['#f54750', '#4e5460', '#4dc0bd', '#fcb364', '#95a1b1'],
      tooltip: {
        trigger: 'item',
        formatter: "{a} <br/>{b}: {c} ({d}%)"
      },
      legend: {
        orient: 'vertical',
        x: 'right',
        top: 'middle',
        data: labels
      },
      series: [
        {
          name:'KOL个性分析',
          type:'pie',
          radius: ['30%', '70%'],
          avoidLabelOverlap: false,
          label: {
              normal: {
                  show: false,
                  position: 'center'
              },
              emphasis: {
                  show: true,
                  textStyle: {
                      fontSize: '18'
                  }
              }
          },
          labelLine: {
              normal: {
                  show: false
              }
          },
          data: tags
        }
      ]
    };

    return <div className="chart-wrapper tag-chart">
      <ReactEcharts height={360} option={option} showLoading={false}/>
    </div>
  }

  renderRegionChart(data) {
    if (!data || data.length == 0) {
      return <div className="region-chart chart-loading">
        数据加载中...
      </div>
    }

    let regions = data.toJS();
    regions = _.map(regions, (obj) => {
      return {
        name: obj["province_short_name"],
        selected: true
      }
    });

    const option = {
      tooltip: {
        trigger: 'item',
        formatter: '{b}'
      },
      series: [
        {
          name: '中国',
          type: 'map',
          mapType: 'china',
          selectedMode : false,
          label: {
            normal: {
              show: false
            },
            emphasis: {
              show: false
            }
          },
          data: regions
        }
      ]
    };

    return <div className="chart-wrapper region-chart">
      <ReactEcharts height={360} option={option} showLoading={false}/>
    </div>
  }


  render() {
    const { analysis_invite_result } = this.props;

    return (
      <div className="page page-activity page-analysis">
        <div className="container">
          <div className="analysis-section">
            <div className="feature feature-gender">
              <h5>KOL性别分析</h5>
              { this.renderGenderChart(analysis_invite_result.get("gender_analysis")) }
            </div>
            <div className="feature feature-age">
              <h5>KOL年龄分析</h5>
              { this.renderAgeChart(analysis_invite_result.get("age_analysis")) }
            </div>
            <div className="feature feature-tag">
              <h5>KOL个性分析</h5>
              { this.renderTagChart(analysis_invite_result.get("tag_analysis")) }
            </div>
            <div className="feature feature-tag">
              <h5>KOL地域分析</h5>
              { this.renderRegionChart(analysis_invite_result.get("region_analysis")) }
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default connect(select)(AnalysisCampaignInvitePartial)
