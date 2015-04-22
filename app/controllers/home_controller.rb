class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @ranking_title = t(:hot_papers)
    @ranking_papers = Paper.ranking.limit(10)
    @department_title = 'あなたの科の人気論文'
    @department_papers = Paper.search_by_department(current_user.department).limit(10)
    @favorite_title = 'マイお気に入り'
    @favorite_papers = current_user.favorite_list.papers.limit(10)
  end
end
