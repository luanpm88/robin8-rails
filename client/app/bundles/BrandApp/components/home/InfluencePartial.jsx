import React from 'react';

export default class InfluencePartial extends React.Component {
  render() {
    return (
      <div className="panel my-linfluence-panel">
        <div className="panel-heading">
          <a href="#paneLinfluence" data-toggle="collapse" className="switch"><span className="txt">收起</span><i className="caret-arrow" /></a>
          <h4 className="panel-title">我的品牌影响力</h4>
        </div>
        <div id="paneLinfluence" className="panel-collapse collapse in">
          <div className="panel-body">
            <p className="infl-stat-info">在过去的<strong className="stat-num">24</strong>小时内，被提及<strong className="stat-num">123456789</strong>次</p>
            {/* 引入品牌影响力组件 */}
            {/* 品牌影响力组件 S */}
            <div className="brand-influence-area">
              {/* 图表 S */}
              <div className="infographic-influence-box">
                <div className="infographic-show clearfix">
                  <p className="stat stat-good">
                    <i className="icon-good">赞</i>
                    <strong className="stat-num">70<i>%</i></strong><span className="txt">认为你很赞</span>
                  </p>
                  <div className="inf-show inf-good" style={{width: '70%'}} />
                  <div className="inf-show inf-bad" style={{width: '30%'}} />
                  <p className="stat stat-bad">
                    <i className="icon-bad">烂</i>
                    <span className="txt">认为你很烂</span><strong className="stat-num">30<i>%</i></strong>
                  </p>
                </div>
              </div>
              {/* 图表 E */}
              {/* 标签云 S */}
              <div className="tags-influence-box clearfix">
                <div id="tagsGoodBox" className="tags-box pull-left jqcloud" style={{width: 260, height: 100}}><span id="tagsGoodBox_word_0" className="w10" style={{position: 'absolute', left: 100, top: '32.5px'}}>经典</span><span id="tagsGoodBox_word_2" className="w10" style={{position: 'absolute', left: '172.358px', top: '35.5821px'}}>时尚</span><span id="tagsGoodBox_word_3" className="w7" style={{position: 'absolute', left: '50.6879px', top: '54.7356px'}}>激情</span><span id="tagsGoodBox_word_4" className="w4" style={{position: 'absolute', left: '130.389px', top: '13.6327px'}}>好喝</span><span id="tagsGoodBox_word_5" className="w1" style={{position: 'absolute', left: '17.0914px', top: '46.0931px'}}>温情</span></div>
                <div id="tagsBadBox" className="tags-box pull-right jqcloud" style={{width: 260, height: 100}}><span id="tagsBadBox_word_0" className="w10" style={{position: 'absolute', left: 85, top: '32.5px'}}>高热量</span><span id="tagsBadBox_word_1" className="w7" style={{position: 'absolute', left: '121.814px', top: '5.55139px'}}>咖啡因</span><span id="tagsBadBox_word_2" className="w4" style={{position: 'absolute', left: '47.4043px', top: '40.7069px'}}>太甜</span><span id="tagsBadBox_word_3" className="w1" style={{position: 'absolute', left: '125.203px', top: '74.7728px'}}>难喝</span></div>
              </div>
              {/* 标签云 E */}
            </div>
            {/* 品牌影响力组件 E */}
            <a href="#" className="btn btn-grey btn-big btn-line center-block">查看详情</a>
          </div>
        </div>
      </div>
    );
  }
}
