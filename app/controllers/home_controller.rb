class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @papers = Paper.ranking
    @title = t(:hot_papers)
  end
end
