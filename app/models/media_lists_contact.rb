class MediaListsContact < ActiveRecord::Base
  belongs_to :media_list
  belongs_to :contact
end
