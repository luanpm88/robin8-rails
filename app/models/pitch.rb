class Pitch < ActiveRecord::Base
  has_many :pitches_contacts
  has_many :contacts, through: :pitches_contacts
  belongs_to :user
  belongs_to :release

  validates_inclusion_of :email_targets, :twitter_targets, in: [true, false]
  validates :user, twitter_connect: true, if: :twitter_targets?
  validates_presence_of :user_id
  validates_presence_of :release_id
  validates_numericality_of :release_id
  validates :email_address, email_format: true, allow_blank: true
  validates_length_of :email_address, maximum: 255
  validates_length_of :email_subject, maximum: 2500
  validates_numericality_of :summary_length,
    greater_than_or_equal_to: 1, less_than_or_equal_to: 10
  validates_presence_of :twitter_pitch, if: :twitter_targets?
  validates_presence_of :email_pitch, :email_subject,
    :email_address, if: :email_targets?
  validate :can_be_created, on: :create

  after_create :decrease_feature_number
  after_destroy :increase_feature_number

  private

  def can_be_created
    errors.add(:user, "you've reached the max numbers of smart content.") if needed_user && !needed_user.can_create_smart_release
  end

  def email_targets?
    email_targets
  end

  def twitter_targets?
    twitter_targets
  end

  def needed_user
    user.is_primary? ? user : user.invited_by
  end

  def decrease_feature_number
    af = needed_user.user_features.smart_release.available.joins(:product).where(products: {is_package: false}).first
    uf = af.nil? ? needed_user.user_features.smart_release.available.first : af
    return false if uf.blank?
    uf.available_count -= 1
    uf.save
  end

  def increase_feature_number
    af = needed_user.user_features.smart_release.used.joins(:product).where(products: {is_package: false}).first
    uf = af.nil? ? needed_user.user_features.smart_release.used.first : af
    return false if uf.blank?
    uf.available_count += 1
    uf.save
  end
end
