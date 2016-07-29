Kaminari.configure do |config|
  config.page_method_name = :per_page_kaminari
end

if defined?(WillPaginate)
  module WillPaginate
    module ActiveRecord
      module RelationMethods
        alias_method :per, :per_page
        alias_method :padding, :offset
        alias_method :num_pages, :total_pages
        alias_method :total_count, :count
        alias_method :prev_page, :previous_page
      end
    end
  end
end
