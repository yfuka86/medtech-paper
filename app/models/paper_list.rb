class PaperList < ActiveRecord::Base
  has_many :paper_paper_lists
  has_many :papers, through: :paper_paper_lists
  belongs_to :user

  enum category: [:general, :favorite, :read]

  def self.setup_with_newuser(user)
    favorite_paper_list = self.new(title: 'お気に入り', category: :favorite)
    read_paper_list = self.new(title: '読んだ論文', category: :read)
    user.paper_lists << favorite_paper_list << read_paper_list
    user.save
  end

end
