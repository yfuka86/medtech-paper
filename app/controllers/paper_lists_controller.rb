class PaperListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @paper_lists = current_user.paper_lists
    @title = '抄読会（論文リスト）一覧'
  end

  def search
  end

  def show
    @paper_list = current_user.paper_lists.find_by(id: params[:id])
    @papers = @paper_list.papers
  end

  def new
    @paper_list = PaperList.new
  end

  def create
    paper_list = PaperList.new(paper_params)
    paper_list.user = current_user
    if paper_list.save
      redirect_to paper_lists_path, notice: '論文リストが保存されました'
    else
      redirect_to new_paper_lists_path, alert: '論文リストの保存に失敗しました'
    end
  end

  def edit
  end

  def update
  end

  def add_paper
  end

  def destroy
  end

  private

  def paper_params
    params.require(:paper_list).permit(:title, :is_public)
  end

  def add_paper_params
    params.permit(:id, :pubmed_id)
  end
end
