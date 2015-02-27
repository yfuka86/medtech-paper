class PaperListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @paper_lists = current_user.paper_lists
    @title = '抄読会（論文リスト）一覧'
  end

  def show
    @paper_list = current_user.paper_lists.find_by(id: params[:id])
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
    @paper_list = current_user.paper_lists.find_by(id: params[:id])
  end

  def update
    paper_list = current_user.paper_lists.find_by(id: params[:id])
    paper_list.assign_attributes(paper_params)
    if paper_list.save
      redirect_to paper_list_path(id: paper_list.id), notice: '論文リストの編集が完了しました'
    else
      redirect_to edit_paper_list_path(id: paper_list.id), alert: '論文リストの編集に失敗しました'
    end
  end

  def destroy
    paper_list = current_user.paper_lists.find_by(id: params[:id])
    if paper_list.try(:destroy)
      redirect_to paper_lists_path, notice: '論文リストが削除されました'
    else
      redirect_to paper_lists_path, alert: '論文リストの削除に失敗しました'
    end
  end

  def add_paper
    paper = Pubmed.fetch(add_paper_params[:pubmed_id])
    paper_list = current_user.paper_lists.find_by(id: add_paper_params[:id])

    redirect_to search_papers_path, alert: "#{paper_list.title}にはこの論文がすでに登録されています" and return if paper_list.papers.find_by(id: paper.try(:id)).present?
    paper_list.papers << paper
    if paper.save && paper_list.save
      redirect_to paper_list_path(id: paper_list.id), notice: "#{paper_list.title}に論文が登録されました"
    else
      redirect_to search_papers_path, alert: "#{paper_list.title}への論文の登録に失敗しました"
    end
  end

  def remove_paper
    relation = PaperPaperList.find_by(paper_list_id: remove_paper_params[:id], paper_id: remove_paper_params[:paper_id])
    binding.pry
    paper = relation.paper
    paper_list = relation.paper_list
    if relation.destroy
      redirect_to paper_list_path(id: paper_list.id), notice: "#{paper_list.title}から論文#{': ' + paper.title if paper.title.present?}が削除されました"
    else
      redirect_to paper_list_path(id: paper_list.id), notice: "#{paper_list.title}からの論文#{': ' + paper.title if paper.title.present?}の削除に失敗しました"
    end
  end

  def search
  end

  private

  def paper_params
    params.require(:paper_list).permit(:title, :is_public)
  end

  def add_paper_params
    params.permit(:id, :pubmed_id)
  end

  def remove_paper_params
    params.permit(:id, :paper_id)
  end
end
