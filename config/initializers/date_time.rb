# encoding: utf-8
Time::DATE_FORMATS[:time]='%H:%M'
Time::DATE_FORMATS[:date_time_without_year]='%m-%d %H:%M'
Time::DATE_FORMATS[:date_time]='%Y-%m-%d %H:%M'
Time::DATE_FORMATS[:date]='%Y-%m-%d'
Time::DATE_FORMATS[:year_month]='%Y-%m'
Time::DATE_FORMATS[:month_day]='%m-%d'
Time::DATE_FORMATS[:all_time]='%Y-%m-%d %H:%M:%S'
Time::DATE_FORMATS[:contracts]='%m.%d %H:%M'
Time::DATE_FORMATS[:end_at]='%y-%m-%d %H:%M:%S'
Time::DATE_FORMATS[:zh_date] = '%Y年%m月%d日'
Time::DATE_FORMATS[:zh_day] = '%d日'
Time::DATE_FORMATS[:unionpay] = '%Y%m%d%H%M%S'



def interval_time(_start, _end)
  return [0,0,0]  if _end <= _start
  interval_seconds = _end.to_i - _start.to_i
  day, remain_seconds = interval_seconds.divmod  24 * 60 * 60
  hour, remain_seconds = remain_seconds.divmod  60 * 60
  minute = remain_seconds / 60
  return [day, hour, minute]
end
