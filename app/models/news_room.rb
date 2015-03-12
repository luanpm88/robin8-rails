class NewsRoom < ActiveRecord::Base
  VALID_TYPES = ['Government Agency', 'Non-Profit', 'Privately Held', 'Public Company', 'LLC', 'Educational Institution']
  VALID_SIZES = ['Myself Only', '1-5 employees', '6-10 employees', '11-50 employees', '51-200 employees',
                  '201-500 employees', '501-1000 employees', '1001-5000 employees', '5001-10,000 employees', '10,001 or more employees'
                ]

  belongs_to :user
  has_and_belongs_to_many :industries
  has_many :releases, dependent: :destroy
  has_many :attachments, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true
  before_create :set_campaign_name

  validates :company_name, presence: true
  validates :user_id, presence: true
  validates :subdomain_name, presence: true, uniqueness: true
  # validates :campaign_name, uniqueness: true
  validates_inclusion_of :room_type, in: VALID_TYPES, allow_blank: true
  validates_inclusion_of :size, in: VALID_SIZES, allow_blank: true
  
  def city_state
    [city, state].join(', ')
  end

  private
  
    def set_campaign_name
      self.campaign_name = self.company_name
    end
    
end
