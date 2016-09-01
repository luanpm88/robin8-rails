module Crm
  class Seller < ActiveRecord::Base
    has_secure_password

    has_many :customers
    has_many :notes
  end
end
