json.array!(@iptc_categories) do |iptc_category|
  json.extract! iptc_category, :id, :parent, :level
  json.label iptc_category.label.split.map(&:capitalize).join(' ')
end
