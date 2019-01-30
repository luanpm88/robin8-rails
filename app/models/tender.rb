class Tender < ActiveRecord::Base

  STATUS = {
    pending:   '待合作',
    rejected:  '已拒绝',
    paid:      '已支付',
  }

  belongs_to :creation 
  belongs_to :kol
  belongs_to :creation_selected_kol
  has_many   :sub_tenders, class_name: "Tender", foreign_key: :parent_id
  has_many   :transactions, -> {where(item_type: 'Tender')}, class_name: "Transaction", foreign_key: :item_id

  after_create :update_quoted
  before_save  :update_status, if: ->{self.head && self.status_changed? && self.status == "paid"}

  scope :by_status,   ->(status){where(status: status).order(updated_at: :desc)}
  

  def show_info
    "平台：#{from_terrace} | 报价：¥#{price} | 状态：#{status_zh} | 作品链接：#{link}"
  end

  def brand_show_info
    "#{from_terrace} | 发帖数：0 | 报价：¥#{price} | 曝光值：0"
  end



  def status_zh
    CreationSelectedKol::STATUS[creation_selected_kol.status.to_sym]
  end
  
  def amount
    self.price + self.fee
  end

  def climb_info
  end

  private 

  def update_quoted
    unless self.head # head true 父订单
      if self.creation_selected_kol.present?
        self.creation_selected_kol.update_columns(status: 'pending')
      else
        # 生成自主报价的creation_selected_kol
        self.creation_selected_kol = CreationSelectedKol.create(
          plateform_name: self.from_terrace, 
          creation_id:    self.creation_id, 
          kol_id:         self.kol_id, 
          from_by:        'volunteered', 
          status:         'pending'
        )
        self.update_columns(creation_selected_kol_id: self.creation_selected_kol.id)
        # todo 去大数据中完善creation_selectd_kol
      end
    end
  end

  # 品牌主批量支付报价，对应的creation_selected_kol设为已付款， 接下来的所有交互都是跟creation_selected_kol有关
  # 直到平台付款给大V时，拿对应的selected_kol下面tender状态为paid去支付.
  def update_status
    self.sub_tenders.update_all(status: 'paid')
    self.sub_tenders.each do |t|
      t.creation_selected_kol.update_attributes(status: 'paid')
    end
  end
  
end
