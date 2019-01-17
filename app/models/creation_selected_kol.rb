class CreationSelectedKol < ActiveRecord::Base


	# select: 品牌主选择的, recommend: 平台推荐的, volunteered :kol自主报名的
	validates_inclusion_of :from_by, in: %w(select recommend volunteered)

  belongs_to :creation
  belongs_to :kol

  has_many :tenders


  scope :is_quoted, ->{ where(quoted: true)}
  
end
