import React from 'react';
import _ from 'lodash';

export default class Targets extends React.Component {

  constructor(props, context) {
    super(props, context);
    this.state = {kol_count: 0};
    this.initSelector = false;
  }

  componentDidUpdate() {
    const campaign = this.props.campaign;
    if(!this.initSelector && campaign.size) {
      let region_text = campaign.get("region").split("/").join(",");
      let tag_text = campaign.get("tags").map((item) => {
        return item;
      }).join(",");

      let sns_text = campaign.get("sns_platforms").map((item) => {
        return item;
      }).join(",");

      this.fetchKolCountWithConditions({region: region_text, tag: tag_text, sns: sns_text});
      this.initSelector = true;
    }
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

  renderTargetTitle(){
    const tip = "<p>选择地域、分数等条件，我们将根选中条件将招募活动推送给最合适的KOL用户</p>"
    return tip
  }

  renderKOlCount(){
    return <div className="notice">预计推送KOL人数 <em> {this.state.kol_count} 人</em></div>
  }

  renderSnsLogo() {
    const campaign = this.props.campaign;
    var snsItems = [];
    let sns;
    if(sns = campaign.get("sns_platforms")) {
      sns.map((s) => {
        if(s == "全部") {
          $("#sns-result").html("全部");
        } else {
          const element =
          <div
            key={`sns-${s}`}
            className={`target-item sns-icon icon-${s}`}>
          </div>
          snsItems.push(element);
        }
      })
    }
    return snsItems;
  }

  render() {
    const campaign = this.props.campaign;
    return (
      <div className="show-activity">
        <div className="header">
          <h3 className="tit">KOL选择&nbsp;<span className="what"  data-toggle="tooltip"  title={this.renderTargetTitle()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="panel content">
          <div className="campaign-target-group">

            {this.renderKOlCount()}

            <div className="row">
              <div className="col-md-4">
                <div className="campaign-target target-region">
                  <label >地区</label>
                  <div className="target-result">
                    <div id="btn_jobArea" className="target-city-label">{campaign.get("region")}</div>
                  </div>
                </div>
              </div>
              <div className="col-md-4">
                <div className="campaign-target target-profession">
                  <label>分类</label>
                  <div className="target-result">
                    <div id="profession-result">{campaign.get("tag_labels") ? campaign.get("tag_labels").join('/') : ''}</div>
                  </div>
                </div>
              </div>
              <div className="col-md-4">
                <div className="campaign-target target-sns">
                  <label>平台</label>
                  <div className="target-result">
                    <div id="sns-result">{this.renderSnsLogo()}</div>
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
