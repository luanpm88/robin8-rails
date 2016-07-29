import React from 'react';
import { jobAreaSelect } from '../../shared/CitySelector';

export default class TargetPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ["_addTriggerTargetRegionInputChange"])
  }

  _addTriggerTargetRegionInputChange(){
    const { onChange } = this.props;
    onChange({
      region: $('.target-city-label').text()
    });
  }

  componentDidMount(){
    $(".target-city-label").bind("change", this._addTriggerTargetRegionInputChange)
  }

  renderTargetTitle(){
    const tip = "<p>选择地域、分数等条件，我们将根选中条件将招募活动推送给最合适的KOL用户</p>"
    return tip
  }

  render() {
    const { region } = this.props;
    return (
      <div className="creat-activity-form">
        <div className="header">
          <h3 className="tit">搜索KOL&nbsp;<span className="what"  data-toggle="tooltip"  title={this.renderTargetTitle()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="content">
          <div className="campaign-target">
            <div className="form-group">
              <div className="target-region-range">
                <label >地区</label>
                <div className="target-region-selector">
                  <span id="btn_jobArea" className="target-city-label" readOnly="readonly"></span>
                </div>
                <a className="btn btn-blue btn-default region-button" onClick={ (event) => { jobAreaSelect()}}>选择地区</a>
              </div>
            </div>
          </div>
        </div>
      </div>
     )
   }
 }
