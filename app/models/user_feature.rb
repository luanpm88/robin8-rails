class UserFeature < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  belongs_to :feature

  scope :newsroom,                   -> { joins(:feature).where(features: { slug: 'newsroom' }) }
  scope :seat,                       -> { joins(:feature).where(features: { slug: 'seat' }) }
  scope :press_release,              -> { joins(:feature).where(features: { slug: 'press_release' }) }
  scope :smart_release,              -> { joins(:feature).where(features: { slug: 'smart_release' }) }
  scope :media_monitoring,           -> { joins(:feature).where(features: { slug: 'media_monitoring' }) }
  scope :personal_media_list,        -> { joins(:feature).where(features: { slug: 'personal_media_list' }) }
  scope :myprgenie_web_distribution, -> { joins(:feature).where(features: { slug: 'myprgenie_web_distribution' }) }
  scope :accesswire_distribution,    -> { joins(:feature).where(features: { slug: 'accesswire_distribution' }) }
  scope :pr_newswire_distribution,   -> { joins(:feature).where(features: { slug: 'pr_newswire_distribution' }) }
  scope :available,                  -> { where('available_count > 0') }
  scope :not_available,              -> { where('available_count = 0') }
  scope :used,                       -> { where('available_count < max_count') }

end