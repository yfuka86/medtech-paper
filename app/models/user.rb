class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :paper_lists, dependent: :delete_all
  has_many :paper_list_users, dependent: :delete_all
  has_many :shared_paper_lists, through: :paper_list_users, class_name: 'PaperList'
end
