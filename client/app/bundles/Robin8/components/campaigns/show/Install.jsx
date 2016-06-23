import React, { PropTypes } from 'react';
import ReactEcharts from '../../shared/ReactEcharts';

export default class Install extends React.Component{
  constructor(props, context){
    super(props, context);
  }

  componentDidMount() {
    const { fetchInstallOfCampaign } = this.props.actions;
    fetchInstallOfCampaign(this.props.campaign_id);      
  }

  generate_echarts_options(){
    const option = {
    tooltip : {
        trigger: 'item',
        formatter: "{a} <br/>{b} : {c} ({d}%)"
    },
    legend: {
        orient: 'vertical',
        left: 'left',
        data: ['Ios用户','Android用户']
    },
    series : [
        {
            name: '访问来源',
            type: 'pie',
            radius : '55%',
            center: ['50%', '60%'],
            data:[
                {value:335, name:'Ios用户'},
                {value:310, name:'Android用户'}
            ],
            itemStyle: {
                emphasis: {
                    shadowBlur: 10,
                    shadowOffsetX: 0,
                    shadowColor: 'rgba(0, 0, 0, 0.5)'
                }
            }
        }
    ]
  };

  return option;
  }

  render(){
    const options = this.generate_echarts_options()
    return(
      <div className="panel install-charts-panel">
        <div className="panel-heading">
          <a href="#installChartsPanel" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
          <h4 className="panel-title">安装用户统计</h4>
        </div>
        <div id="installChartsPanel" className="panel-collapse collapse in">
          <div className="panel-body">
            <div className="influence-charts-area">
              { do 
                {
                  // if(campaign.get("total_click") === 0){
                  //   <div className="panel-body showMiddleTip">
                  //     暂时没有安装用户
                  //   </div>
                  // }else{
                    <ReactEcharts height={500} option={options}  showLoading={false}/>
                  //}
                }
              }
            </div>
          </div>
        </div>
      </div>
    )
  }
}