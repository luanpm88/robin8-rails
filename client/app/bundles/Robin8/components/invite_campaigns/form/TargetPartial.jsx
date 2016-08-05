import React from 'react';
import _ from "lodash";
import { jobAreaSelect } from '../../shared/CitySelector';
import TagSelector from '../../shared/TagSelector';
import SnsSelector from '../../shared/SnsSelector';
import PriceRangeSelector from '../../shared/PriceRangeSelector';

export default class TargetPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, ["handleConditionChange", "initConditionComponent"])
  }

  handleConditionChange(){
    let condition = {};

    const regionText = $('.target-city-label').text().trim();
    if (regionText != "全部") {
      const condstr = regionText.split("/").join(",");
      _.assignIn(condition, {region: condstr});
    }

    const tagItems = this.tagSelector.activeItems;
    if (tagItems.length > 0) {
      const condstr = tagItems.map((item) => {
        return item.name;
      }).join(",");
      _.assignIn(condition, {tag: condstr});
    }

    const snsItems = this.snsSelector.activeItems;
    if (snsItems.length > 0) {
      const condstr = snsItems.map((item) => {
        return item.name;
      }).join(",");
      _.assignIn(condition, {sns: condstr});
    }

    const { minValue, maxValue } = this.priceRangeSelector;
    if (minValue >= 0 && maxValue > minValue) {
      const condstr = [ minValue, maxValue ].join(",");
      _.assignIn(condition, {price_range: condstr});
    }

    this.props.onChange(condition);
  }

  initConditionComponent() {
    $(".target-city-label").bind("change", this.handleConditionChange)

    this.tagSelector = new TagSelector({
      onSelectionDone: (activeItems, state=true) => {
        let activeText;

        if (activeItems.length > 0) {
          activeText = activeItems.map((item) => {
            return item.label;
          }).join("/");
        }

        $("#tag-result").html(activeText || "全部");
        if (!!state) this.handleConditionChange();
      }
    });

    this.snsSelector = new SnsSelector({
      onSelectionDone: (activeItems, state=true) => {
        let activeText;

        if (activeItems.length > 0) {
          activeText = activeItems.map((item) => {
            return `<span class="target-item sns-icon icon-${item.name}"></span>`;
          }).join("");
        }

        $("#sns-result").html(activeText || "全部");
        if (!!state) this.handleConditionChange();
      }
    });

    this.priceRangeSelector = new PriceRangeSelector({
      onSelectionDone: (minValue, maxValue, state=true) => {
        let priceResult;

        if (minValue >= 0 && maxValue > 0) {
          priceResult = `${minValue} <span class="strip">-</span> ${maxValue}`;
        }

        $("#price-range-result").html(priceResult || "全部");
        if (!!state) this.handleConditionChange();
      }
    });

    this.snsSelector.set();
    this.tagSelector.set();
    this.priceRangeSelector.set();
  }

  componentDidMount(){
    this.initConditionComponent();
    this.handleConditionChange();
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
          <div className="campaign-target-group">

            <div className="row">
              <div className="col-md-3">
                <div className="campaign-target target-region">
                  <label >地区</label>
                  <a className="btn btn-blue btn-default target-btn"
                     onClick={ (event) => { jobAreaSelect()}}>选择地区</a>
                  <div className="target-result">
                    <div id="btn_jobArea" className="target-city-label">全部</div>
                  </div>
                </div>
              </div>
              <div className="col-md-3">
                <div className="campaign-target target-tag">
                  <label>分类</label>
                  <a className="btn btn-blue btn-default target-btn"
                     onClick={ (event) => { this.tagSelector.show() }}>选择分类</a>
                  <div className="target-result">
                    <div id="tag-result"></div>
                  </div>
                </div>
              </div>
              <div className="col-md-3">
                <div className="campaign-target target-sns">
                  <label>平台</label>
                  <a className="btn btn-blue btn-default target-btn"
                     onClick={ (event) => { this.snsSelector.show() }}>社交媒体</a>
                  <div className="target-result">
                    <div id="sns-result"></div>
                  </div>
                </div>
              </div>
              <div className="col-md-3">
                <div className="campaign-target target-price-range">
                  <label>价格</label>
                  <a className="btn btn-blue btn-default target-btn"
                     onClick={ (event) => { this.priceRangeSelector.show() }}>价格区间</a>
                  <div className="target-result">
                    <div id="price-range-result"></div>
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>
     )
   }
 }
