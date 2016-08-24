import React from 'react';
import ReactEcharts from '../../shared/ReactEcharts';

export default class Influnce extends React.Component{
  constructor(props, context){
    super(props, context)
  }

  componentDidMount(){
    const { fetchStatisticsClicksOfCampaign } = this.props.actions;
    fetchStatisticsClicksOfCampaign(this.props.campaign_id);
  }

  generate_echarts_options(){
    const { campaign_statistics } = this.props;
    const legend = [];
    const clicks = [];
    const colors = []
    if(campaign_statistics.size != 4){
      return {}
    }

    if(campaign_statistics.get(0) == "post"){
      legend.push("总点击");
      colors.push('#f98b33');
      clicks.push({
            name: '总点击',
            type:'line',
            stack: '总量',
            areaStyle: {normal: {}},
            data: Array.from(campaign_statistics.get(2))
          })
    }else{
      colors.push('#f98b33');
      colors.push('#62e6fb');
      legend.push("计费点击");
      legend.push("总点击");
      clicks.push({
            name: '计费点击',
            type:'line',
            stack: '总量',
            areaStyle: {normal: {}},
            data: Array.from(campaign_statistics.get(3))
          })

      clicks.push({
            name: '总点击',
            type:'line',
            stack: '总量',
            areaStyle: {normal: {}},
            data: Array.from(campaign_statistics.get(2))
          })
      // click.push({
      //       name: '总点击',
      //       type:'line',
      //       stack: '总量',
      //       areaStyle: {normal: {}},
      //       data: Array.from(campaign_statistics.get(2))
      //     })
    }
    const options = {
      tooltip : {
        trigger: 'axis'
      },
      legend: {
        data: Array.from(legend),
        bottom: '1%'
      },
      grid: {
        left: '3%',
        right: '4%',
        top: "3%",
        bottom: '10%',
        containLabel: true
      },
      xAxis : [
        {
          type : 'category',
          boundaryGap : false,
          data : Array.from(campaign_statistics.get(1))
        }
      ],
      yAxis : [
        {
          type : 'value'
        }
      ],
      series : Array.from(clicks),
      color: colors
    };
    console.log('----legend--');
    console.log(clicks)
    return options
  }

  render(){
    const options = this.generate_echarts_options();
    const { campaign } = this.props;
    return(
      <div className="panel influence-charts-panel">
        <div className="panel-heading">
          <a href="#influenceChartsPanel" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
          <h4 className="panel-title">参与情况</h4>
        </div>
        <div id="influenceChartsPanel" className="panel-collapse collapse in">
          <div className="panel-body">
            <div className="influence-charts-area">
              { do
                {
                  if(campaign.get("total_click") === 0) {
                    <div className="panel-body showMiddleTip">
                      暂时没有Kol点击
                    </div>
                  } else {
                    if(options.series)
                      <ReactEcharts height={500} option={options}  showLoading={false}/>
                  }
                }
              }
            </div>
          </div>
        </div>
      </div>
    )
  }
}
