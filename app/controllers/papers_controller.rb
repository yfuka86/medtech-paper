class PapersController < ApplicationController
  before_action :authenticate_user!

  def index
    @papers = Paper.search(search_params).page(params[:page]).per(20)
  end

  def api_index
    redirect_to action: 'api_search' if api_search_params.try(:[], :term).blank?
    @papers = Pubmed.search(api_search_params)
    @title = '検索結果'
  end

  def api_search
  end

  private

  def search_params
    params.permit(:keyword, :min_date, :max_date, :author_name, :journal_name, :sort)
  end

  def api_search_params
    params.permit(:term, :mindate, :maxdate)
  end
end
