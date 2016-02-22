module API
  module V1
    module Entities
      module WithdrawEntities
        class Summary  < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :real_name, :credits, :withdraw_type, :alipay_no, :bank_name, :bank_no, :status, :remark
          with_options(format_with: :iso_timestamp) do
            expose :created_at
          end
        end
      end
    end
  end
end
