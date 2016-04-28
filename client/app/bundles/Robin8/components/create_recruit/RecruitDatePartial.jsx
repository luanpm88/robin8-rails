import React from 'react';
import moment from 'moment';
import {} from '../shared/bootstrap-datetimepicker'

export default class RecruitDatePartial extends React.Component {

  constructor(props, context) {
    super(props, context);
    _.bindAll(this, '_initDateTimePicker')
  }

  _initDateTimePicker() {

    const datepickerStartOptions = {
      ignoreReadonly: true,
      locale: 'zh-cn',
      format: 'YYYY-MM-DD HH:mm',
      minDate: moment().format("YYYY-MM-DD HH:mm")
    }

    const datepickerEndOptions = {
      ignoreReadonly: true,
      locale: 'zh-cn',
      format: 'YYYY-MM-DD HH:mm',
      useCurrent: false,
    }
    $('#recruit-start-time-datepicker').datetimepicker(datepickerStartOptions);
    $('#recruit-deadline-datepicker').datetimepicker(datepickerEndOptions);

    $("#recruit-start-time-datepicker").on("dp.change", function (e) {
      $('#recruit-deadline-datepicker').data("DateTimePicker").minDate(e.date);
      $('#deadline-datepicker').data("DateTimePicker").minDate(e.date);
      $('#start-time-datepicker').data("DateTimePicker").minDate(e.date);
    });
  }

  componentDidMount() {
    this._initDateTimePicker();
  }

  renderDateTips(){
    const tip = "<p>1.&nbsp;报名开始时间，即允许KOL开始报名，此时品牌的活动信息将在Robin8平台展示；</p>\
                 <p>2.&nbsp;报名结束时间，即KOL截止报名的时间；</p>\
                 <p>3.&nbsp;截止报名后品牌可以确定招募名单；</p>\
                 <p>4.&nbsp;报名时间至少为1天</p>"
    return tip
  }
  render() {

    const { recruit_start_time, recruit_end_time } = this.props

    return (
      <div className="creat-activity-form creat-date">
        <div className="header">
          <h3 className="tit">报名时间&nbsp;<span className="what" data-toggle="tooltip" title={this.renderDateTips()}>?</span></h3>
        </div>
        <div className="content">
          <div className="date-range-form-area input-daterange">
            <div className="date-box satrt-date">
              <label>报名开始时间</label>
              <input {...recruit_start_time}  type="text" className="form-control" id="recruit-start-time-datepicker" name="startDate" readOnly required />
            </div>
            <div className="date-box end-date">
              <label>报名截止时间</label>
              <input {...recruit_end_time} type="text" className="form-control" id="recruit-deadline-datepicker" name="endDate" readOnly required />
            </div>
          </div>
        </div>
      </div>
    )
  }
}
