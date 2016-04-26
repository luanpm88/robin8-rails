import React, { PropTypes } from "react";
import moment from "moment-timezone";
import "moment-duration-format";

export default class StateText extends React.Component {
  constructor(props, context){
    super(props, context);
    moment.tz.setDefault("Asia/Shanghai");
  }

  count_down(){
    const { campaign } = this.props;
    let interval, duration_text;

    const current_time = moment(),
      end_time = moment(campaign.get("recruit_end_time")),
      seconds = end_time.diff(current_time, 'seconds');

    if (seconds > 60) {
      const minutes = end_time.diff(current_time, 'minutes');
      duration_text = moment.duration(minutes + 1, "minutes").format("d[天] h[小时] m[分钟]");
    } else {
      duration_text = moment.duration(seconds, "seconds").format("s[秒]");
    }

    if (seconds <= 0) {
      window.location.reload();
    }

    this.refs.timeText.innerHTML = duration_text;

    setTimeout(function() {
      this.count_down();
    }.bind(this), 1000);
  }

  componentDidUpdate() {
    const { campaign } = this.props;

    if (campaign.get("recruit_status") === "inviting") {
      this.count_down();
    }
  }

  renderContent() {
    const { campaign } = this.props;
    const status = campaign.get("recruit_status");

    if (status === "inviting") {
      return (
        <div className="content">
          距离报名截止还有 <span ref="timeText" className="remaining-time"></span>
        </div>
      );
    } else if (status === "choosing") {
      return (
        <div className="content">
          请确认您的招募名单
        </div>
      );
    } else if (status === "running") {
      return (
        <div className="content">
          以下是您确认后的名单
        </div>
      );
    }
  }

  render(){
    const { campaign } = this.props;

    return(
      <div className="state-text">
        { this.renderContent() }
      </div>
    );
  }
}