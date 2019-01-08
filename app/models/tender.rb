class Tender < ActiveRecord::Base
  belongs_to :creation 
  belongs_to :kol_id

  STATUS = {
    pending:          '待合作',
    rejected:         '不合作',
    unpay:            '确认合作，待付款',
    paid:             '确认合作，已付款',
    uploaded:         '作品上传，待验收',
    approved:         '验收满意，待结款',
    finished:         '结款成功，合作完成'
  }
end
