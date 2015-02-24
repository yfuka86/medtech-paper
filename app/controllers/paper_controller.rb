class PaperController < ApplicationController
  def search
  end

  def index
    @papers = Paper.ranking
    @title = '検索結果'
  end

  def add
  end
end
