import React, { PropTypes } from "react";
import moment from 'moment';
import "moment-duration-format";

export default class Counter extends React.Component {
  constructor(props, context){
    super(props, context);
  }

  count_down(){
    const { campaign } = this.props;
    let current_time = moment(),
      end_time = moment(campaign.get("deadline")),
      duration = end_time.diff(current_time, 'minutes'),
      duration_text = moment.duration(duration, "minutes").format("d[天] h[小时] m[分钟]");

    this.refs.timeText.innerHTML = duration_text;

    // setTimeout(function() {
    //   // count_down();
    // }, 1000 * 60);
  }

  componentDidMount() {
    this.count_down()
  }

  render(){
    const { campaign } = this.props;

    return(
      <div className="counter-text">
        <div className="content">
          距离报名截止还有 <span ref="timeText" className="remaining-time"></span>
        </div>
      </div>
    );
  }
}