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
    analysis_result: state.campaignReducer.get("analysis_result")
  }
}

class AnalysisCampaignPartial extends React.Component {
  constructor(props, context) {
    super(props, context);
    _.bindAll(this, [
      "getAnalysisUrl",
      "renderCategoryChart",
      "renderSentimentChart",
      "renderProductChart",
      "renderPersonChart",
      "renderKeywordChart"
    ])
  }

  componentDidMount() {
    const { analysisCampaign } = this.props.actions;
    const url = this.getAnalysisUrl();
    if (!!url) {
      analysisCampaign(url);
    } else {
      alert("无法获取将要分析的URL")
    }
  }

  componentWillUnmount() {
    this.props.actions.clearAnalysisCampaign();
  }

  getAnalysisUrl() {
    return _.get(this.props, ['location', 'query', 'url']);
  }

  renderCategoryChart(data) {
    if (!data || data.length == 0) {
      return <div className="category-chart chart-loading">
        数据加载中...
      </div>
    }

    let categories = _.slice(data.toJS(), 0, 5);

    categories = _.map(categories, (obj) => {
      return {
        name: obj["label"],
        value: obj["probability"]
      }
    });

    let labels = _.map(categories, (obj) => {
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
          name:'文章类别',
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
          data: categories
        }
      ]
    };

    return <div className="chart-wrapper category-chart">
      <ReactEcharts height={360} option={option} showLoading={false}/>
    </div>
  }

  renderSentimentChart(data) {
    if (!data || data.length == 0) {
      return <div className="sentiment-chart chart-loading">
        数据加载中...
      </div>
    }

    let sentiments = data.toJS();

    sentiments = _.map(sentiments, (obj) => {
      return {
        name: (obj["label"] == "positive" ? "积极" : "消极"),
        value: obj["probability"]
      }
    });

    let labels = _.map(sentiments, (obj) => {
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
          name:'情感分析',
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
          data: sentiments
        }
      ]
    };

    return <div className="chart-wrapper sentiment-chart">
      <ReactEcharts height={360} option={option} showLoading={false}/>
    </div>
  }

  renderProductChart(data) {
    if (!data || data.length == 0) {
      return <div className="product-chart chart-loading">
        数据加载中...
      </div>
    }

    let products = _.slice(data.toJS(), 0, 6);

    products = _.map(products, (obj) => {
      return {
        name: obj["label"],
        value: obj["freq"]
      }
    });

    let labels = _.map(products, (obj) => {
      return obj["name"];
    });

    let values = _.map(products, (obj) => {
      return obj["value"];
    })

    const option = {
      color: ['#f54750'],
      tooltip : {
        trigger: 'axis',
        axisPointer : {
          type : 'shadow'
        }
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis : [
        {
          type : 'category',
          data : labels,
          axisTick: {
            alignWithLabel: true
          }
        }
      ],
      yAxis : [
        {
          type : 'value'
        }
      ],
      series : [
        {
          name:'频数',
          type:'bar',
          barWidth: '30%',
          data: values
        }
      ]
    };

    return <div className="chart-wrapper product-chart">
      <ReactEcharts height={360} option={option} showLoading={false}/>
    </div>
  }

  renderPersonChart(data) {
    if (!data || data.length == 0) {
      return <div className="person-chart chart-loading">
        数据加载中...
      </div>
    }

    let persons = _.slice(data.toJS(), 0, 6);

    persons = _.map(persons, (obj) => {
      return {
        name: obj["label"],
        value: obj["freq"]
      }
    });

    let labels = _.map(persons, (obj) => {
      return obj["name"];
    });

    let values = _.map(persons, (obj) => {
      return obj["value"];
    })

    const option = {
      tooltip : {
        trigger: 'axis',
        axisPointer : {
          type : 'shadow'
        }
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis : [
        {
          type : 'category',
          data : labels,
          axisTick: {
            alignWithLabel: true
          }
        }
      ],
      yAxis : [
        {
          type : 'value'
        }
      ],
      series : [
        {
          name:'频数',
          type:'bar',
          barWidth: '50%',
          data: values
        }
      ],
      color: ['#4dc0bd']
    };

    return <div className="chart-wrapper person-chart">
      <ReactEcharts height={360} option={option} showLoading={false}/>
    </div>
  }

  renderKeywordChart(data) {
    if (!data || data.length == 0) {
      return <div className="keyword-chart chart-loading">
        数据加载中...
      </div>
    }

    let words = _.map(data.toJS(), (obj) => {
      return {
        text: obj["label"],
        weight: obj["probability"]
      }
    });

    return <div className="chart-wrapper keyword-chart">
      <WordCloud height={240} words={words} />
    </div>
  }

  render() {
    const { analysis_result } = this.props;

    return (
      <div className="page page-activity page-analysis">
        <div className="container">
          <ol className="breadcrumb">
            <li>
              <i className="caret-arrow left" />
              {/*<Link to={`/brand/campaigns/new`}>返回去发布活动</Link>*/}
              <a onClick={window.close}>返回去发布活动</a>
            </li>
          </ol>
          <div className="analysis-section">
            <div className="feature feature-link">
              <h5>文章链接</h5>
              <div className="link-text">
                <a target="_blank" href={ this.getAnalysisUrl() }>{ this.getAnalysisUrl() }</a>
              </div>
            </div>
            <div className="feature feature-info">
              <h5>文章内容</h5>
              <div className="info-text">{analysis_result.get("text")}</div>
            </div>
            <div className="feature feature-category">
              <h5>文章类别</h5>
              { this.renderCategoryChart(analysis_result.get("categories")) }
            </div>
            <div className="feature feature-sentiment">
              <h5>情感分析</h5>
              { this.renderSentimentChart(analysis_result.get("sentiment")) }
            </div>
            <div className="feature feature-product">
              <h5>产品服务</h5>
              { this.renderProductChart(analysis_result.get("products")) }
            </div>
            <div className="feature feature-person">
              <h5>人物品牌</h5>
              { this.renderPersonChart(analysis_result.get("persons_brands")) }
            </div>
            <div className="feature feature-keyword">
              <h5>关键词云</h5>
              { this.renderKeywordChart(analysis_result.get("keywords")) }
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default connect(select)(AnalysisCampaignPartial)
