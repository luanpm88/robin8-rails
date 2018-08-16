module API
  module V1_3
    module Entities
      module TransactionEntities
        class Summary  < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :credits, :amount, :avail_amount, :frozen_amount
          expose :subject do |transaction|
            transaction.get_subject_by_app
          end
          expose :direct do |transaction|
            transaction.get_direct
          end
          expose :remark do |transaction|
            if transaction.item_type == 'Withdraw'
              transaction.item.reject_reason
            else
              ''
            end
          end
          with_options(format_with: :iso_timestamp) do
            expose :created_at
          end
        end

        class Stat  < Grape::Entity
          expose :credits, :amount, :avail_amount, :frozen_amount
        end
      end
    end
  end
end
