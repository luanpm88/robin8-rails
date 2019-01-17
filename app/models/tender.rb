class Tender < ActiveRecord::Base

  STATUS = {
    pending:          '待合作',
    rejected:         '不合作',
    unpay:            '确认合作，待付款',
    paid:             '确认合作，已付款',
    uploaded:         '作品上传，待验收',
    approved:         '验收满意，待结款',
    finished:         '结款成功，合作完成'
  }


  belongs_to :creation 
  belongs_to :kol
  belongs_to :creation_selected_kol

  after_create :update_quoted



  private 

  def update_quoted
    creation_selected_kol.update_columns(quoted: true)
  end

  
end
