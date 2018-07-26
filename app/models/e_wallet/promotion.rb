class EWallet::Promotion < ActiveRecord::Base
  default_scope { where(state: true) }
end
