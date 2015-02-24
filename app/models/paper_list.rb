class PaperList < ActiveRecord::Base
  has_many :paper_paper_lists
  has_many :papers, through: :paper_paper_lists
  belongs_to :user
end
