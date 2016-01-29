class StasticData < ActiveRecord::Base
  after_create :async_stastic_data

  def async_stastic_data
    StasticDataHandler.perform_async self.id
  end
end