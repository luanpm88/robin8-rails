module Open
  module V1
    module Entities
      module Transaction
        class TransactionList < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :credits, :amount, :avail_amount, :frozen_amount
          expose :subject do |transaction|
            transaction.get_subject
          end
          expose :direct do |transaction|
            transaction.get_direct
          end
          with_options(format_with: :iso_timestamp) do
            expose :created_at
          end
        end
      end
    end
  end
end