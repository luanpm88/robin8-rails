import React from 'react';

export default class DatePartial extends React.Component {

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
