import React from 'react';
import _ from 'lodash';
import { jobAreaSelect } from '../../shared/CitySelector';
import TagSelector from '../../shared/TagSelector';
import SnsSelector from '../../shared/SnsSelector';

export default class TargetPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    this.state = {kol_count: 0};
    _.bindAll(this, ["handleConditionChange", "initConditionComponent"])
  }

  fetchKolCountWithConditions(condition) {
    let params = [];
    _.forIn(condition, (value, key) => params.push(`${key}=${value}`));
    params.push("just_count=true");
    const queryString = params.join("&");

    fetch(`/brand_api/v1/kols/search?${queryString}`, {"credentials": "include"})
      .then(function(response) {
        response.json().then(function(data){
          this.setState({kol_count: data.count});
      }.bind(this))
    }.bind(this),
    function(error) {
      console.error("----------查询kol数量失败---------------")
    })
  }

  handleConditionChange(){

    let condition = {};

    const regionText = $('.target-city-label').text().trim();
    if (regionText != "全部") {
      const condstr = regionText.split("/").join(",");
      _.assignIn(condition, {region: condstr});
      this.props.region.onChange(condstr)
    }

    const professionItems = this.professionSelector.activeItems;
    if (professionItems.length > 0) {
      const condstr = professionItems.map((item) => {
        return item.name;
      }).join(",");
      _.assignIn(condition, {profession: condstr});
      this.props.profession.onChange(condstr)
    }

    const snsItems = this.snsSelector.activeItems;
    if (snsItems.length > 0) {
      const condstr = snsItems.map((item) => {
        return item.name;
      }).join(",");
      _.assignIn(condition, {sns: condstr});
      this.props.sns_platform.onChange(condstr)
    }

    this.fetchKolCountWithConditions(condition);
  }

  initConditionComponent() {
    $(".target-city-label").bind("change", this.handleConditionChange)

    this.professionSelector = new TagSelector({
      onSelectionDone: (activeItems, state=true) => {
        let activeText;

        if (activeItems.length > 0) {
          activeText = activeItems.map((item) => {
            return item.label;
          }).join("/");
        }

        $("#profession-result").html(activeText || "全部");
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

    this.snsSelector.set();
    this.professionSelector.set();
  }

  componentDidMount(){
    this.initConditionComponent();
    this.handleConditionChange();
  }

  renderTargetTitle(){
    const tip = "<p>选择地域、分数等条件，我们将根选中条件将招募活动推送给最合适的KOL用户</p>"
    return tip
  }

  renderKOlCount(){
    if (this.state.kol_count) {
      return <div className="notice">预计推送KOL人数 <em>{this.state.kol_count} 人</em></div>
    }
  }

  render() {
    // const { region } = this.props;
    return (
      <div className="creat-activity-form">
        <div className="header">
          <h3 className="tit">KOL选择&nbsp;<span className="what"  data-toggle="tooltip"  title={this.renderTargetTitle()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="content">
          <div className="campaign-target-group">

            {this.renderKOlCount()}

            <div className="row">
              <div className="col-md-4">
                <div className="campaign-target target-region">
                  <label >地区</label>
                  <a className="btn btn-blue btn-default target-btn"
                     onClick={ (event) => { jobAreaSelect()}}>选择地区</a>
                  <div className="target-result">
                    <div id="btn_jobArea" className="target-city-label">全部</div>
                  </div>
                </div>
              </div>
              <div className="col-md-4">
                <div className="campaign-target target-profession">
                  <label>分类</label>
                  <a className="btn btn-blue btn-default target-btn"
                     onClick={ (event) => { this.professionSelector.show() }}>选择分类</a>
                  <div className="target-result">
                    <div id="profession-result"></div>
                  </div>
                </div>
              </div>
              <div className="col-md-4">
                <div className="campaign-target target-sns">
                  <label>平台</label>
                  <a className="btn btn-blue btn-default target-btn"
                     onClick={ (event) => { this.snsSelector.show() }}>社交媒体</a>
                  <div className="target-result">
                    <div id="sns-result"></div>
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
