class HelperDoc < ActiveRecord::Base
  attr_accessor :doc_tag
  belongs_to :helper_tag

  validates     :question, uniqueness: {:message => "问题已存在"}, presence: {:message => "问题不能为空"}
  validates     :answer,  presence: {:message => "答案不能为空"}

  # after_find do
  #   self.doc_tag = self.helper_tag.try :title
  # end

  # before_save :set_doc_tag_id

  # def set_doc_tag_id
  #   self.helper_tag_id = HelperTag.find_by(:title => doc_tag).id
  # end
end
