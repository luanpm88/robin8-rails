import React, { Component, PropTypes } from 'react';
import NotificationSystem from "react-notification-system";


export default class NotificationSystemPartial extends Component {
  componentDidMount() {
    const that = this
    $('.notificationData').change(function(){
      const notify_value = $(".notificationData").attr("data-notify")
      console.log("改变了" + notify_value)
      if(notify_value && notify_value.length > 0){
        const notification = {
          title: '保存失败',
          message: notify_value,
          level: $(".notificationData").attr("data-notify-type"),
          position: 'tr',
          autoDismiss: 5
        }
        $(".notificationData").attr("data-notify", "")
        that.refs.notificationSystem.addNotification(notification);
      }
    })
  }

  render(){
    return(
      <div className="notificationData" data-notify="" data-notify-type="">
        <NotificationSystem  ref="notificationSystem" allHTML={false}/>
      </div>
    )
  }
}
