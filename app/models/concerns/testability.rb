module Concerns
  module Testability
    extend ActiveSupport::Concern

    TESTABLE_IDENTIFIER = Rails.application.secrets[:testable] || "【测试】"

    included do
      scope :testable, -> (key = "name") { where("`campaigns`.`#{key}` LIKE ?", "%#{TESTABLE_IDENTIFIER}%") }
      scope :realable, -> (key = "name") { where.not("`campaigns`.`#{key}` LIKE ?", "%#{TESTABLE_IDENTIFIER}%") }
    end
  end
end