import React from 'react';
import _ from 'lodash'
import {ShowError} from '../../shared/ShowError';

export default class EvaluatePartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    //_.bindAll(this, ['_fetchShortUrl', '_listenEffectScoreChange']);
  }

  componentWillUnmount() {
    $('.spinner-input').off('change');
  }

  renderDetailTips(){
    const tip = "<p>1.&nbsp;对活动的效果进行评价。\
                 <p>2.&nbsp;评价提交后将不能修改。\
                 "
    return tip
  }

  render() {
    const { review_content, effect_score  } = this.props
    return (
      <div className="creat-activity-form creat-content-sources">
        <div className="header">
          <h3 className="tit">活动效果评价&nbsp;<span className="what" data-toggle="tooltip" title={this.renderDetailTips()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="content">
          <div className="form-item form-horizontal">
            <div className="row">
              <p className="action-mode">效果打分:</p>
              <div className="sources-check">
                <div className="row">
                  <div className="col-md-3">
                    <input {...effect_score} type="radio" name="effect_score" value="5" onChange={effect_score.onChange} />
                    5分
                  </div>
                  <div className="col-md-3">
                    <input {...effect_score} type="radio" name="effect_score" value="4" onChange={effect_score.onChange}  />
                    4分
                  </div>
                  <div className="col-md-3">
                    <input {...effect_score} type="radio" name="effect_score" value="3" onChange={effect_score.onChange} />
                    3分
                  </div>
                  <div className="col-md-3">
                    <input {...effect_score} type="radio" name="effect_score" value="2" onChange={effect_score.onChange} />
                    2分
                  </div>
                  <div className="col-md-3">
                    <input {...effect_score} type="radio" name="effect_score" value="1" onChange={effect_score.onChange} />
                    1分
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
