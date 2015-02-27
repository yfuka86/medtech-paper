class PaperPaperList < ActiveRecord::Base
  belongs_to :paper
  belongs_to :paper_list
end
