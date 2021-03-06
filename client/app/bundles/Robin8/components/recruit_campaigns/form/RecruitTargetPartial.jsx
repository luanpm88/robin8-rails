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
      console.error("[ERROR] 查询kol数量失败!");
    })
  }

  handleConditionChange(e){

    let condition = {};

    const regionText = $('.target-city-label').text().trim();
    if (regionText != "全部") {
      let condstr = regionText.split("/").join(",");
      _.assignIn(condition, {region: condstr});
      this.props.region.onChange(condstr)
    } else {
      this.props.region.onChange("全部");
    }

    const tagItems = this.tagSelector.activeItems;
    if (tagItems.length > 0) {
      let condstr = tagItems.map((item) => {
        return item.name;
      }).join(",");
      _.assignIn(condition, {tag: condstr});
      this.props.tags.onChange(condstr);
    } else {
      this.props.tags.onChange("全部");
    }

    const snsItems = this.snsSelector.activeItems;
    if (snsItems.length > 0) {
      let condstr = snsItems.map((item) => {
        return item.name;
      }).join(",");
      _.assignIn(condition, {sns: condstr});
      this.props.sns_platforms.onChange(condstr);
    } else {
      this.props.sns_platforms.onChange("全部");
    }

    _.assignIn(condition, { age: this.props.age.value });
    _.assignIn(condition, { gender: this.props.gender.value });

    if (e && e.target.name === 'age'){
      this.props.age.onChange(e.target.value);
      _.assignIn(condition, { age: e.target.value });
      _.assignIn(condition, { gender: this.props.gender.value });
    }

    if (e && e.target.name === 'gender' ){
      this.props.gender.onChange(e.target.value);
      _.assignIn(condition, { gender: e.target.value });
      _.assignIn(condition, { age: this.props.age.value });
    }

    this.fetchKolCountWithConditions(condition);
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
      items: [{
        id: 1,
        label: "微博",
        name: "weibo"
      },{
        id: 2,
        label: "微信",
        name: "wechat"
      }],
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
  }

  componentWillReceiveProps(nextProps) {
    if (!_.get(this.props, ['region', 'value']) &&
        _.get(nextProps, ['region', 'value'])) {

      const { region, tags, sns_platforms:sns, age, gender } = nextProps;

      this.initConditionComponent();
      if(region.value === "全部 全部") region.value = "全部"
      $('.target-city-label').text(region.value);
      this.tagSelector.set(tags.value, false);
      this.snsSelector.set(sns.value, false);

      this.fetchKolCountWithConditions({
        region: region.value.split('/').join(','),
        sns: _.isArray(sns.value) ? sns.value.join(",") : sns.value,
        tag: _.isArray(tags.value) ? tags.value.join(",") : tags.value,
        age: age.value,
        gender: gender.value
      });
    }
  }

  renderTargetTitle(){
    const tip = "<p>选择地域、分数等条件，我们将根选中条件将招募活动推送给最合适的KOL用户</p>"
    return tip
  }

  renderKolCount(){
    return <div className="notice">预计推送KOL人数 <em>{this.state.kol_count} 人</em></div>
  }

  render() {
    const { age, gender } = this.props;

    return (
      <div className="creat-activity-form">
        <div className="header">
          <h3 className="tit">KOL选择&nbsp;<span className="what"  data-toggle="tooltip"  title={this.renderTargetTitle()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="content">
          <div className="campaign-target-group">

            {this.renderKolCount()}

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
                <div className="campaign-target target-tag">
                  <label>分类</label>
                  <a className="btn btn-blue btn-default target-btn"
                     onClick={ (event) => { this.tagSelector.show() }}>选择分类</a>
                  <div className="target-result">
                    <div id="tag-result"></div>
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

            <div className="row row2">
              <div className="col-md-4">
                <div className="campaign-target target-age form-group">
                  <label>年龄</label>
                  <select className="form-control select-age" {...age} value={age.value || ''} onChange={this.handleConditionChange}>
                    <option value="全部">全部</option>
                    <option value="0, 20">0-20</option>
                    <option value="20, 30">20-30</option>
                    <option value="30, 40">30-40</option>
                    <option value="40, 50">40-50</option>
                    <option value="50, 60">50-60</option>
                    <option value="60, 100">60以上</option>
                  </select>
                </div>
              </div>

              <div className="col-md-4">
                <div className="campaign-target target-gender form-group">
                  <label>性别</label>
                  <select className="form-control select-gender" {...gender} value={gender.value || ''} onChange={this.handleConditionChange}>
                    <option value="全部">全部</option>
                    <option value="1">男</option>
                    <option value="2">女</option>
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
