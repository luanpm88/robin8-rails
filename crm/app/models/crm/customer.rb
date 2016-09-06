module Crm
  class Customer < ActiveRecord::Base
    belongs_to :seller
  end
end
