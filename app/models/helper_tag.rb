class HelperTag < ActiveRecord::Base
  validates     :title, uniqueness: {:message => "分类名已存在"}, presence: {:message => "不能为空"}
end
