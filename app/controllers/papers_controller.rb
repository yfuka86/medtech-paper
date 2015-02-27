class PapersController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to action: 'search' if search_params.try(:[], :term).blank?
    @papers = Pubmed.search(search_params)
    @title = '検索結果'
  end

  def search
  end

  private

  def search_params
    params.permit(:term, :mindate, :maxdate)
  end
end
