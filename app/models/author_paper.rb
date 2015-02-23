class AuthorPaper < ActiveRecord::Base
  belongs_to :paper
  belongs_to :author
end
