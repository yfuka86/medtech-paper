class PapersController < ApplicationController
  before_action :authenticate_user!

  def index
    @papers = Paper.search(search_params, current_user).page(params[:page]).per(20)
  end

  def api_index
    redirect_to action: 'api_search' if api_search_params.try(:[], :term).blank?
    @papers = Pubmed.search(api_search_params)
    @title = '検索結果'
  end

  def api_search
  end

  def poly_search
    if params["pubmed_search"].present?
      redirect_to api_index_papers_path(term: params[:term])
    elsif params["medtech_search"].present?
      redirect_to papers_path(term: params[:term])
    else
      redirect_to :back
    end
  end

  private

  def search_params
    params.permit(:term, :min_date, :max_date, :author_name, :journal_name, :sort)
  end

  def api_search_params
    params.permit(:term, :mindate, :maxdate)
  end
end
