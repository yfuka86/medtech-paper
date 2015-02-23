class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @papers = Paper.ranking
    @title = 'ランキング'
  end
end
