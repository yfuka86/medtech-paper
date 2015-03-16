class PaperList < ActiveRecord::Base
  has_many :paper_paper_lists
  has_many :papers, through: :paper_paper_lists
  belongs_to :user
  has_many :paper_list_users, dependent: :delete_all
  has_many :shared_users, through: :paper_list_users, source: :user

  accepts_nested_attributes_for :shared_users

  enum category: [:general, :favorite, :read]

  def self.setup_with_newuser(user)
    favorite_paper_list = self.new(title: 'お気に入り', category: :favorite)
    read_paper_list = self.new(title: '読んだ論文', category: :read)
    user.paper_lists << favorite_paper_list << read_paper_list
    user.save
  end

  def all_users
    shared_users + [user]
  end

  def has_paper?(paper)
    self.papers.find_by(id: paper.id).present?
  end
end
