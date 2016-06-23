import React, { PropTypes } from 'react';
import ReactEcharts from '../../shared/ReactEcharts';

export default class Install extends React.Component{
  constructor(props, context){
    super(props, context);
  }

  componentDidMount() {
    const { fetchInstallsOfCampaign } = this.props.actions;
    fetchInstallsOfCampaign(this.props.campaign_id);      
  }

  generate_echarts_options(){
    const {campaign_installs } = this.props;

    if(campaign_installs.size != 2){
      return
    }

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
                {value: campaign_installs.get(0), name:'Ios用户'},
                {value: campaign_installs.get(1), name:'Android用户'}
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
    const {campaign_installs } = this.props;
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
                  if(campaign_installs.size == 0){
                    <div className="panel-body showMiddleTip">
                      数据加载中...
                    </div>
                  }else if((campaign_installs.size == 2) && campaign_installs.get(0) == 0 && campaign_installs.get(1) == 0){
                    <div className="panel-body showMiddleTip">
                      暂时没有安装用户
                    </div>
                  }else if(campaign_installs.size == 2){
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