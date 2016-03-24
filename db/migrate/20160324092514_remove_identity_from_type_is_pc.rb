class RemoveIdentityFromTypeIsPc < ActiveRecord::Migration
  def change
    Identity.where(:from_type => 'pc').delete_all
  end
end
