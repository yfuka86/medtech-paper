class Journal < ActiveRecord::Base
  has_many :papers

  def self.build_from_params(journal_params)
    exists_journal = self.where(journal_params).first
    if exists_journal
      exists_journal
    else
      self.new(journal_params)
    end
  end
end
