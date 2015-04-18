class Paper < ActiveRecord::Base
  has_many :author_papers
  has_many :authors, through: :author_papers
  has_many :paper_paper_lists
  has_many :paper_lists, through: :paper_paper_lists
  belongs_to :journal

  accepts_nested_attributes_for :authors
  accepts_nested_attributes_for :journal

  validates :pubmed_id, presence: true

  scope :sorter, -> (query, user) do
    return unless query.present?
    ary = query.split('_')
    key = ary[0]
    direction = (ary[1] == 'asc' ? :asc : :desc)
    case key
    when 'title'
      order(title: direction)
    when 'published-date'
      order(published_date: direction)
    when 'popularity'
      joins(:paper_paper_lists).
      group('papers.id').order("COUNT(paper_paper_lists.id) #{direction}")
    when 'favorite'
      if user.present?
        favorite_id = user.favorite_list.id
        joins("LEFT OUTER JOIN
               (SELECT * FROM paper_paper_lists WHERE paper_paper_lists.paper_list_id = #{favorite_id})
               AS relations ON papers.id = relations.paper_id").
        order("CASE WHEN relations.paper_list_id = #{favorite_id} THEN 0 ELSE 1 END #{direction}")
      end
    when 'read-date'
      eager_load(:paper_paper_lists).order("paper_paper_lists.read_date #{direction}")
    else
      eager_load(:paper_paper_lists).order("paper_paper_lists.created_at desc")
    end
  end

  def self.build_from_pubmed(fetch_params={}, summary_params={})
    pmid = fetch_params.try(:[], "pmid").try(:to_i) || summary_params.try(:[], "uid").try(:to_i)
    return nil if pmid.blank?

    already_exists_paper = self.find_by(pubmed_id: pmid)
    return already_exists_paper if already_exists_paper.present?

    paper = self.new
    paper.pubmed_id = pmid

    if fetch_params.present?
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
    end

    summary_params["authors"].uniq{|h| h["name"]}.each do |author|
      if author.is_a?(Hash)
        paper.authors << Author.build_from_params({name: author["name"]})
      end
    end
    paper.authors.uniq

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

  def self.search(params={}, user)
    query = self.all
    if params[:term].present?
      str = "%#{params[:term]}%"
      query = query.where('title like ? OR pubmed_id = ?', str, params[:term])
    end

    query = query.where('? <= published_date', params[:min_date]) if params[:min_date].present?
    query = query.where('published_date <= ?', params[:max_date]) if params[:max_date].present?

    if params[:journal_name].present?
      str = "%#{params[:journal_name]}%"
      query = query.joins(:journal).where('journals.ml_jta like ? or journals.name like ?', str, str)
    end
    if params[:author_name].present?
      str = "%#{params[:author_name]}%"
      query = query.joins(:authors).where('authors.name like ?', str)
    end

    query = query.sorter(params[:sort], user)

    query
  end

  def self.ranking
    self.joins(:paper_paper_lists).group('papers.id').order("COUNT(paper_paper_lists.id) desc")
  end

  def self.search_by_department(department)
    users_ids = User.where(department: department).pluck(:id)
    paper_list_ids = PaperList.where(user_id: users_ids).pluck(:id)
    self.joins("INNER JOIN
               (SELECT * FROM paper_paper_lists WHERE paper_paper_lists.paper_list_id IN (#{paper_list_ids.join(',')}))
               AS relations ON papers.id = relations.paper_id").
        group('papers.id').order("COUNT(relations.id) desc")
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
