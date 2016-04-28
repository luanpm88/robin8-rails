import React from 'react';
import moment from 'moment';
import '../../shared/bootstrap-datetimepicker'


export default class DatePartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, '_initDateTimePicker')
  }

  _initDateTimePicker() {

    const datepickerStartOptions = {
      ignoreReadonly: true,
      locale: 'zh-cn',
      format: 'YYYY-MM-DD HH:mm',
    }

    const datepickerEndOptions = {
      ignoreReadonly: true,
      locale: 'zh-cn',
      format: 'YYYY-MM-DD HH:mm',
      useCurrent: false,
    }
    $('#start-time-datepicker').datetimepicker(datepickerStartOptions);
    $('#deadline-datepicker').datetimepicker(datepickerEndOptions);
  }

  componentDidMount() {
    this._initDateTimePicker();
  }

  renderDateTips(){
    const tip = "<p>1.&nbsp;活动开始时间，即KOL参与品牌活动的时间；</p> \
                 <p>2.&nbsp;活动结束时间，即品牌活动结束的时间；</p> \
                 <p>3.&nbsp;活动时间至少为1小时，且活动开始时间距离报名结束至少为1天</p>"
    return tip
  }
  render() {

    const { start_time, deadline } = this.props

    return (
      <div className="creat-activity-form creat-date">
        <div className="header">
          <h3 className="tit">活动时间&nbsp;<span className="what" data-toggle="tooltip" title={this.renderDateTips()}>?</span></h3>
        </div>
        <div className="content">
          <div className="date-range-form-area input-daterange">
            <div className="date-box satrt-date">
              <label>开始时间</label>
              <input {...start_time}  type="text" className="form-control" id="start-time-datepicker" name="startDate" readOnly required />
            </div>
            <div className="date-box end-date">
              <label>结束时间</label>
              <input {...deadline} type="text" className="form-control" id="deadline-datepicker" name="endDate" readOnly required />
            </div>
          </div>
        </div>
      </div>
    )
  }
}
