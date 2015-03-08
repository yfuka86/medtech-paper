class Paper < ActiveRecord::Base
  has_many :author_papers
  has_many :authors, through: :author_papers
  has_many :paper_paper_lists
  has_many :paper_lists, through: :paper_paper_lists
  belongs_to :journal

  accepts_nested_attributes_for :authors
  accepts_nested_attributes_for :journal

  def self.build_from_pubmed(fetch_params={}, summary_params={})
    pmid = fetch_params["pmid"].try(:to_i)
    already_exists_paper = self.where(pubmed_id: pmid).first
    return already_exists_paper if already_exists_paper.present?

    paper = self.new
    paper.pubmed_id = pmid
    paper.abstract = fetch_params["medent"].try(:[], "abstract")

    fetch_data = fetch_params["medent"].try(:[], "cit")
    # author_data = fetch_data.try(:[], "authors")
    # if author_data.is_a?(Hash) && author_data["names"].is_a?(Hash)
    #   author_data["names"].each do |k, v|
    #     paper.authors << Author.build_from_params({name: v["name ml"]})
    #   end
    # elsif author_data.is_a?(Hash) && author_data["names ml"].present?
    #   paper.authors << Author.build_from_params({name: author_data["names ml"][nil]})
    # end

    journal_data = fetch_data.try(:[], "from journal")
    pubdate = journal_data.try(:[], "imp").try(:[], "date")

    paper.published_date = "#{pubdate["year"]}-#{pubdate["month"].presence || 1}-#{pubdate["day"].presence || 1}" if pubdate.try(:[], "year").present?
    converted_hash = {}
    journal_data.try(:[], "title").try(:each){|k, v| converted_hash[k.gsub('-', '_')] = v}
    paper.journal = Journal.build_from_params(converted_hash)

    summary_params["authors"].each do |author|
      if author.is_a?(Hash)
        paper.authors << Author.build_from_params({name: author["name"]})
      end
    end

    history = summary_params["history"]
    history.each do |hash|
      if hash.is_a?(Hash)
        paper.received_date = hash["date"] if hash["pubstatus"] == 'received'
        paper.accepted_date = hash["date"] if hash["pubstatus"] == 'accepted'
      end
    end if history.is_a?(Hash)
    paper.title = summary_params["title"]
    paper.volume = summary_params["volume"]
    paper.issue = summary_params["issue"]
    paper.pages = summary_params["pages"]

    paper
  end

  def self.ranking
    self.all.sort_by{|p| -p.popularity}
  end

  def popularity
    self.paper_lists.count
  end

  def journal_name
    self.journal.try(:ml_jta)
  end

  def authors_list
    str = self.authors.includes(:author_papers).order('author_papers.id').map{|a| a.name}.join(', ')
    str = self.authors.map{|a| a.name}.join(', ') if str.blank?
    str
  end

  def pubmed_path
    "http://www.ncbi.nlm.nih.gov/pubmed/#{pubmed_id}"
  end
end
