import React, { PropTypes } from 'react';

import { ageHelper, genderHelper } from "../../../helpers/CampaignHelper"

export default class Target extends React.Component{

  constructor(props, context) {
    super(props, context);
    this.state = {kol_count: 0};
    this.initSelector = false;
  }

  componentDidUpdate() {
    const campaign = this.props.campaign;
    if(!this.initSelector && campaign.size) {
      let region_text = "全部";
      if(campaign.get("region")) {
        region_text = campaign.get("region").split("/").join(",");
      }
      let tag_text = "全部";
      if(campaign.get("tags")) {
        tag_text = campaign.get("tags").map((item) => {
          return item;
        }).join(",");
      }

      this.fetchKolCountWithConditions({region: region_text, tag: tag_text});
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

  renderKolCount(){
    return <div className="notice">预计推送KOL人数 <em> {this.state.kol_count} 人</em></div>
  }

  render() {
    const campaign = this.props.campaign;
    return (
      <div className="show-activity">
        <div className="header">
          <h3 className="tit">KOL选择</h3>
        </div>
        <div className="panel content">
          <div className="campaign-target-group">

            {this.renderKolCount()}

            <div className="row">
              <div className="col-md-6">
                <div className="campaign-target target-region">
                  <label >地区</label>
                  <div className="target-result">
                    <div id="btn_jobArea" className="target-city-label">{campaign.get("region") ? campaign.get("region") : '全部'}</div>
                  </div>
                </div>
              </div>
              <div className="col-md-6">
                <div className="campaign-target target-profession">
                  <label>分类</label>
                  <div className="target-result">
                    <div id="profession-result">{campaign.get("tag_labels") ? campaign.get("tag_labels").join('/') : '全部'}</div>
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
