import React from 'react';
import moment from 'moment';

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
    $("#start-time-datepicker").on("dp.change", function (e) {
      $('#deadline-datepicker').data("DateTimePicker").minDate(e.date);
    });
    $("#deadline-datepicker").on("dp.change", function (e) {
        $('#start-time-datepicker').data("DateTimePicker").maxDate(e.date);
    });
  }

  componentDidMount() {
    this._initDateTimePicker();
  }

  render() {

    const { start_time, deadline } = this.props

    return (
      <div className="creat-activity-form creat-date">
        <div className="header">
          <h3 className="tit">推广时间&nbsp;<span className="what">?</span></h3>
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
