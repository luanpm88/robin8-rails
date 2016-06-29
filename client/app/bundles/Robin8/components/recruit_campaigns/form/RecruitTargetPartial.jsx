import React from 'react';
import { jobAreaSelect } from '../../shared/CitySelector';

export default class TargetPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ["_addTriggerTargetRegionInputChange"])
  }

  _addTriggerTargetRegionInputChange(){
    const { onChange } = this.props.region;
    onChange($('.target-city-label').text())
  }

  componentDidMount(){
    $(".target-city-label").bind("change", this._addTriggerTargetRegionInputChange)
  }

  renderTargetTitle(){
    const tip = "<p>选择地域、分数等条件，我们将根选中条件将招募活动推送给最合适的KOL用户</p>"
    return tip
  }

  render() {
    const { influence_score, region} = this.props;
    return (
      <div className="creat-activity-form creat-target">
        <div className="header">
          <h3 className="tit">招募人群&nbsp;<span className="what"  data-toggle="tooltip"  title={this.renderTargetTitle()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="content">
          <div className="creat-recruit-target">
            <div className="form-group">
              <div className="target-region-range">
                <label >地区</label>
                <div className="target-region-selector">
                  <label id="btn_jobArea" className="target-city-label" readOnly="readonly">{region.value}</label>
                </div>
                <a className="btn btn-blue btn-default create-recruit-region-button" onClick={ (event) => { jobAreaSelect()}}>选择地区</a>
              </div>
              <div className="target-influence-score clearfix" >
                <label>影响力分数</label>
                <div className="influence-score-selector">
                  <select {...influence_score} className="influence_score">
                    <option value="gt_400">400分以上</option>
                    <option value="gt_450">450分以上</option>
                    <option value="gt_500">500分以上</option>
                    <option value="gt_550">550分以上</option>
                    <option value="gt_600">600分以上</option>
                    <option value="gt_650">650分以上</option>
                    <option value="gt_700">700分以上</option>
                    <option value="gt_750">750分以上</option>
                    <option value="gt_800">800分以上</option>
                    <option value="gt_900">900分以上</option>
                  </select>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
     )
   }
 }
