class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :paper_lists, dependent: :delete_all
  has_many :paper_list_users, dependent: :delete_all
  has_many :shared_paper_lists, through: :paper_list_users, source: :paper_list

  validates :username, length: { maximum: 20 }
  validates :hospital_name, length: { maximum: 50 }
  validate :valid_username?
  validate :valid_prefecture?

  enum department: [:gastroenterology, :cardiology, :pulmonology, :nephrology,
                    :endocrinology, :diabetes, :collagen_disease, :allergie, :hematology,
                    :neurology, :infection_disease, :oncology, :er, :anesthesiology,
                    :obstetrics_and_gynaecology, :psychiatry, :urology, :otorhinolaryngology,
                    :ophthalmology, :surgery, :orthopaedics, :plastic_surgery, :neurosurgery,
                    :radiology, :dermatology, :pediatrics, :clinical, :basic, :others]

  def valid_username?
    if username.present? && User.find_by(username: username).present?
      errors[:base] << 'ユーザー名は既に使用されています'
      false
    end
    true
  end

  def valid_prefecture?
    if prefecture.present? && !prefecture.in?(Constants::PREFECTURES.values)
      errors[:base] << '都道府県名が不正です'
      false
    end
    true
  end

  def all_paper_lists
    PaperList.by_user(self)
  end

  def display_name
    username.presence || email
  end

  def favorite_list
    paper_lists.favorite.find_by(user_id: id)
  end
end
