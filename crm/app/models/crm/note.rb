module Crm
  class Note < ActiveRecord::Base
    belongs_to :case
    belongs_to :customer
  end
end
