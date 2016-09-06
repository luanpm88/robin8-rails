module Crm
  class Case < ActiveRecord::Base
    has_many :notes
  end
end
