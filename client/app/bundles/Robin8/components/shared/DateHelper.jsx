import moment from 'moment';

export default function format_date(date, format="YYYY-M-D h:mm"){
    return moment(date).format(format)
}
