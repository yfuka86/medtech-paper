class Journal < ActiveRecord::Base
  has_many :papers

  def self.build_from_params(journal_params)
    given_journal = self.where(journal_params).first
    if given_journal
      given_journal
    else
      self.new(journal_params)
    end
  end
end
