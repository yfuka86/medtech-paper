class PaperController < ApplicationController
  def search
  end

  def index
    @paper = Pubmed.search(search_params).map{|pubmed| pubmed.to_paper}
    @title = '検索結果'
  end

  def add
  end

  private

  def search_params
    params.permit(:term, :min_date, :max_date)
  end
end
