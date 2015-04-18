class PaperList < ActiveRecord::Base
  has_many :paper_paper_lists, dependent: :delete_all
  has_many :papers, through: :paper_paper_lists
  belongs_to :user
  has_many :paper_list_users, dependent: :delete_all
  has_many :shared_users, through: :paper_list_users, source: :user

  accepts_nested_attributes_for :shared_users

  enum category: [:general, :read, :favorite, :history]

  scope :by_superuser, -> (user){ where(user_id: user.id) }
  scope :by_user, -> (user) do
    joins('LEFT OUTER JOIN paper_list_users ON paper_list_users.paper_list_id = paper_lists.id').
    where("paper_lists.user_id = #{user.id} OR paper_list_users.user_id = #{user.id}")
  end

  def self.setup_with_newuser(user)
    history_paper_list = self.new(title: '閲覧履歴', category: :history)
    favorite_paper_list = self.new(title: 'お気に入り', category: :favorite)
    read_paper_list = self.new(title: '読んだ論文', category: :read)
    user.paper_lists << history_paper_list << favorite_paper_list << read_paper_list
    user.save
  end

  def self.search(params)
    query = self.where(is_public: true)
    if params[:keyword].present?
      str = "%#{params[:keyword]}%"
      query = query.where('title like ?', str)
    end
    if params[:category].present?
      query = query.where(category: self.categories[params[:category]])
    end
    if params[:username].present?
      query = query.joins(:user).where('users.username = ? OR users.email = ?', params[:username], params[:username])
    end
    query
  end

  def all_users
    shared_users + [user]
  end

  def has_paper?(paper)
    self.papers.find_by(id: paper.id).present?
  end
end
