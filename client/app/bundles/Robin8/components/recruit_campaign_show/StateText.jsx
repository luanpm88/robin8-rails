import React, { PropTypes } from "react";
import moment from 'moment';
import "moment-duration-format";

export default class StateText extends React.Component {
  constructor(props, context){
    super(props, context);
  }

  count_down(){
    const { campaign } = this.props;
    let self = this;

    let current_time = moment(),
      end_time = moment(campaign.get("recruit_end_time")),
      duration = end_time.diff(current_time, 'minutes'),
      duration_text = moment.duration(duration, "minutes").format("d[天] h[小时] m[分钟]");

    this.refs.timeText.innerHTML = duration_text;

    setTimeout(function() {
      self.count_down();
    }, 1000 * 60);
  }

  componentDidUpdate() {
    if (this.props.status === "inviting") {
      this.count_down();
    }
  }

  renderContent() {
    if (this.props.status === "inviting") {
      return (
        <div className="content">
          距离报名截止还有 <span ref="timeText" className="remaining-time"></span>
        </div>
      );
    } else if (this.props.status === "choosing") {
      return (
        <div className="content">
          请确认您的招募名单
        </div>
      );
    } else if (this.props.status === "running") {
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