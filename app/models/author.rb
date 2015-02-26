class Author < ActiveRecord::Base
  has_many :author_papers
  has_many :papers, through: :author_papers

  validates :name, presence: true, uniqueness: true

  def self.build_from_params(author_params)
    given_author = self.where(author_params).first
    if given_author
      given_author
    else
      self.new(author_params)
    end
  end
end
