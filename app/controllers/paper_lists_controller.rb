class PaperListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @paperlists = []
  end

  def search
  end

  private

  def search_params
    params.permit(:term, :mindate, :maxdate)
  end
end
