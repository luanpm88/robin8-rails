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
  has_many   :tenders, class_name: "Tender", foreign_key: :parent_id

  scope :pending, -> {where("status = 'pending'")}
  scope :unpay,   -> {where("status = 'unpay'")}
  scope :paid,    -> {where("status = 'paid'")}

  after_create :update_quoted

  def can_upload?
    %w(paid uploaded).include? status
  end

  private 

  def update_quoted
    if self.creation_selected_kol.present?
      self.creation_selected_kol.update_columns(quoted: true)
    else
      self.creation_selected_kol = CreationSelectedKol.create(creation_id: self.creation_id, kol_id: self.kol_id, from_by: 'volunteered', quoted: true)
    end
  end
  
end
