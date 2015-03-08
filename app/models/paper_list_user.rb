class PaperListUser < ActiveRecord::Base
  belongs_to :paper_list
  belongs_to :user
end
