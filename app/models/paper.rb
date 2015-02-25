class Paper < ActiveRecord::Base
  has_many :author_papers
  has_many :authors, through: :author_papers
  belongs_to :journal

  accepts_nested_attributes_for :authors
  accepts_nested_attributes_for :journal

  def self.build_from_pubmed(fetch_params, summary_params)
    paper = self.new
    paper.pubmed_id = id = fetch_params["pmid"]
    paper.abstract = fetch_params["medent"]["abstract"]

    fetch_data = fetch_params["medent"]["cit"]
    journal_data = fetch_data["from journal"]
    pubdate = journal_data["imp"]["date"]

    paper.published_date = "#{pubdate["year"]}-#{pubdate["month"]}-#{pubdate["day"]}"
    paper.journal = Journal.build_from_params(journal_data["title"])
    journal_data["authors"]["names"].each do |k, v|
      paper.authors << Author.build_from_params({name: v["name ml"]})
    end

    summary_data = summary_params["result"]["#{id}"]
    history = summary_data["history"]
    history.each do |k, v|
      paper.received_date = v["date"] if v["pubstatus"] == 'received'
      paper.accepted_date = v["date"] if v["pubstatus"] == 'accepted'
    end
    paper.title = summary_data["title"]
    paper.volume = summary_data["volume"]
    paper.issue = summary_data["issue"]
    paper.pages = summary_data["pages"]

    paper
  end

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
