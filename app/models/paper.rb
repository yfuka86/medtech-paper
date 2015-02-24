class Paper < ActiveRecord::Base
  has_many :author_papers
  has_many :authors, through: :author_papers
  belongs_to :journal

  accepts_nested_attributes_for :authors

  def self.ranking
    self.all
  end

  def popularity
    10
  end

  def journal_name
    self.journal.symbol
  end

  def authors_list
    self.authors.map{|a| a.name}.join(' ')
  end

  def pubmed_path
    "http://www.ncbi.nlm.nih.gov/pubmed/#{pubmed_id}"
  end
end
