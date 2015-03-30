class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @ranking_title = t(:hot_papers)
    @ranking_papers = Paper.ranking.limit(10)
    @favorite_title = 'マイお気に入り'
    @favorite_papers = current_user.favorite_list.papers.limit(10)
  end
end
