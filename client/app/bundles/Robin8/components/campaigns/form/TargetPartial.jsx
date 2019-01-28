import React from 'react';
import _ from 'lodash';
import { jobAreaSelect } from '../../shared/CitySelector';
import TagSelector from '../../shared/TagSelector';

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
      console.error("----------查询kol数量失败---------------");
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
    if (tagItems && tagItems.length > 0) {
      let condstr = tagItems.map((item) => {
        return item.name;
      }).join(",");
      _.assignIn(condition, {tag: condstr});
      this.props.tags.onChange(condstr);
    } else {
      this.props.tags.onChange("全部");
    }

    _.assignIn(condition, { age: this.props.age.value });
    _.assignIn(condition, { gender: this.props.gender.value });
    _.assignIn(condition, { enable_append_push: this.props.enable_append_push.value });

    if (e && e.target.name === 'age'){
      this.props.age.onChange(e.target.value);
      _.assignIn(condition, { age: e.target.value });
      _.assignIn(condition, { gender: this.props.gender.value });
      _.assignIn(condition, { enable_append_push: this.props.enable_append_push.value });
    }

    if (e && e.target.name === 'gender' ) {
      this.props.gender.onChange(e.target.value);
      _.assignIn(condition, { age: this.props.age.value });
      _.assignIn(condition, { gender: e.target.value });
      _.assignIn(condition, { enable_append_push: this.props.enable_append_push.value });
    }

    if (e && e.target.name === 'enable_append_push' ) {
      this.props.enable_append_push.onChange(e.target.value);
      _.assignIn(condition, { age: this.props.age.value });
      _.assignIn(condition, { gender: this.props.gender.value });
      _.assignIn(condition, { enable_append_push: e.target.value });
    }

    console.log(condition);
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
  }

  componentWillReceiveProps(nextProps) {
    const { region, tags, age, gender, enable_append_push } = nextProps;

    if (this.tagSelector) {
      let tagsValue = tags.value;
      if (!_.isArray(tagsValue) && tagsValue != "全部") {
        tagsValue = tagsValue.split(',');
      }
      this.tagSelector.set(tagsValue, false);
    }

    if (!_.get(this.props, ['region', 'value']) &&
        _.get(nextProps, ['region', 'value'])) {

      this.initConditionComponent();

      if(region.value === "全部 全部") region.value = "全部"
      $('.target-city-label').text(region.value);
      this.tagSelector.set(tags.value, false);

      region.value = region.value.split("/").join(",");
      this.props.region.onChange(region.value);
      this.fetchKolCountWithConditions({
        region: region.value.split('/').join(','),
        tag: _.isArray(tags.value) ? tags.value.join(",") : '全部',
        age: age.value,
        gender: gender.value,
        enable_append_push: enable_append_push.value
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

  renderKolAppendTips() {
    return <div className="notice center">Robin8会优先推送最精准的匹配KOL，6个小时后活动未消耗完会进行补推，推送给第二梯队的匹配KOL，依次类推。</div>
  }

  render() {
    const { age, gender, enable_append_push } = this.props;
    return (
      <div className="creat-activity-form">
        <div className="header">
          <h3 className="tit">KOL选择&nbsp;<span className="what"  data-toggle="tooltip"  title={this.renderTargetTitle()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="content">
          <div className="campaign-target-group">

            {/* this.renderKolCount() */}
            {this.renderKolAppendTips()}

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

              <div className="col-md-2">
                <div className="campaign-target target-age form-group">
                  <label>年龄</label>
                  <select className="form-control select-age" {...age} value={age.value || ''} data-val={age.value} onChange={this.handleConditionChange}>
                    <option value="全部">全部</option>
                    <option value="0, 20">0-20 岁</option>
                    <option value="20, 30">20-30 岁</option>
                    <option value="30, 40">30-40 岁</option>
                    <option value="40, 50">40-50 岁</option>
                    <option value="50, 60">50-60 岁</option>
                    <option value="60, 100">60 岁以上</option>
                  </select>
                </div>
              </div>

              <div className="col-md-2">
                <div className="campaign-target target-gender form-group">
                  <label>性别</label>
                  <select className="form-control select-gender" {...gender} value={gender.value || ''} data-val={gender.value} onChange={this.handleConditionChange}>
                    <option value="全部">全部</option>
                    <option value="1">男</option>
                    <option value="2">女</option>
                  </select>
                </div>
              </div>

              <div className="col-md-2">
                <div className="campaign-target target-enable-append-push form-group">
                  <label>补推</label>
                  <select className="form-control select-enable-append-push" {...enable_append_push} value={enable_append_push.value || ''} data-val={enable_append_push.value} onChange={this.handleConditionChange}>
                    <option value="true">允许补推</option>
                    <option value="false">禁止补推</option>
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
