class CreationSelectedKol < ActiveRecord::Base

	STATUS = {
		preelect: '预选', # brand选择或admin推荐的初始值
		pending:  '已报价，待品牌主确认', # （自主）报名的初始值
		unpay:    '确认合作，未支付',
		paid:     '确认合作，已支付，等待上传作品',
		uploaded: '已上传作品，等侍验收',
		approved: '验收成功，等待付款',
		finished: '付款成功，合作完成',
		rejected: '已拒绝合作' # 只用于后台统计，当preelet, pending, unpay，这三种状态并未得到brand支付确认时，我们会将此条记录在15天后置为拒绝
	}


	# select: 品牌主选择的, recommend: 平台推荐的, volunteered :kol自主报名的
	validates_inclusion_of :from_by, in: %w(select recommend volunteered)
	validates_inclusion_of :status,  in: STATUS.keys.collect{|ele| ele.to_s}

  belongs_to :creation
  belongs_to :kol

  has_many :tenders


  scope :by_status,   ->(status){where(status: status).order(updated_at: :desc)}
  scope :cooperation, ->{ where(status: %w(unpay paid uploaded approved)).order(updated_at: :desc)}
  scope :valid,       ->{ where.not(status: %w(preelect pending rejected)).order(updated_at: :desc)}
  scope :quoted,      ->{ where.not(status: "preelect").order(updated_at: :desc)}
  scope :last_days,   ->(num){where("updated_at > ?", num.days.ago)}


  after_save :check_creation_status

  def can_upload?
    %w(paid uploaded).include? status
  end

  def status_zh
  	STATUS[status.to_sym]
  end

  private 

  def check_creation_status
    result = (self.creation.creation_selected_kols.map &:status).uniq
    result.delete_if {|r| r == "finished" or r == "rejected" or r == "preelect"}  

    self.creation.update_column(:status, "finished") if result.blank?
  end
  
end
