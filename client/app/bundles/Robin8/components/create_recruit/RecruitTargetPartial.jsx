import React from 'react';

export default class TargetPartial extends React.Component {

  constructor(props, context) {
    super(props, context);
  }


  componentDidMount() {
  }

  render() {
    const { influence_score } = this.props;
    return (
      <div className="creat-activity-form creat-target">
        <div className="header">
          <h3 className="tit">招募人群&nbsp;<span className="what">?</span></h3>
        </div>
        <div className="content">
          <div className="creat-activity-target">
            <div className="form-group">
              <div className="target-region-range">
                <label>地区</label>
                <div className="target-age-selector">
                  <h1>xx</h1>
                </div>
              </div>
              <div className="target-influence-score clearfix" >
                <label>影响力分数</label>
                <div className="influence-score-selector">
                  <select {...influence_score} className="influence_score">
                    <option value="more_than_600">600分以上</option>
                    <option value="more_than_700">700分以上</option>
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
