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

  componentDidMount() {
    //const {  effect_score } = this.props;
    //effect_score.onChange("5")
    //console.log("effect_score.value")
    //console.log(effect_score.value)
  }

  renderDetailTips(){
    const tip = "<p>1.&nbsp;对活动的效果进行评价。\
                 <p>2.&nbsp;评价提交后将不能修改。\
                 "
    return tip
  }

  render() {
    const { review_content, effect_score  } = this.props;
    return (
      <div className="creat-activity-form creat-content-sources">
        <div className="header">
          <h3 className="tit">活动效果评价&nbsp;<span className="what" data-toggle="tooltip" title={this.renderDetailTips()}><span className="question-sign">?</span></span></h3>
        </div>
        <div className="content">
          <div className="form-item form-horizontal">
            <div className="row effect-score-row">
              <p className="action-mode">效果打分:</p>
              <div className="sources-check">
                <div className="row">
                  <div className="col-md-2">
                    <input {...effect_score} type="radio" name="effect_score" value="5" onChange={effect_score.onChange} checked={effect_score.value === "5"}/>
                    5分
                  </div>
                  <div className="col-md-2">
                    <input {...effect_score} type="radio" name="effect_score" value="4" onChange={effect_score.onChange}  checked={effect_score.value === "4"}/>
                    4分
                  </div>
                  <div className="col-md-2">
                    <input {...effect_score} type="radio" name="effect_score" value="3" onChange={effect_score.onChange} checked={effect_score.value === "3"}/>
                    3分
                  </div>
                  <div className="col-md-2">
                    <input {...effect_score} type="radio" name="effect_score" value="2" onChange={effect_score.onChange} checked={effect_score.value === "2"}/>
                    2分
                  </div>
                  <div className="col-md-2">
                    <input {...effect_score} type="radio" name="effect_score" value="1" onChange={effect_score.onChange} checked={effect_score.value === "1"}/>
                    1分
                  </div>
                </div>
              </div>
              <div className="sources-check second">
                <ShowError field={effect_score} />
              </div>
            </div>

            <div className="row review-content-row">
              <p className="action-mode">效果评价:</p>
              <div className="sources-check">
                <textarea {...review_content} className="form-control common-textarea activity-intro-input" maxLength={500} placeholder="活动效果评价或者建议, 可以帮助我们提升服务" ></textarea>
                <ShowError field={review_content} />
                <span className="word-limit">10-500</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
