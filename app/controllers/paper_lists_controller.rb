class PaperListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @paper_lists = current_user.all_paper_lists
    @title = '抄読会（論文リスト）一覧'
  end

  def show
    @paper_list = current_user.paper_lists.find_by(id: params[:id]) ||
                  current_user.shared_paper_lists.find_by(id: params[:id]) ||
                  PaperList.where(is_public: true).find_by(id: params[:id])
    @papers = @paper_list.papers.sorter(params[:sort], current_user)
  end

  def new
    @paper_list = PaperList.new
  end

  def shared_new
    @paper_list = PaperList.new
  end

  def create
    paper_list = assign_params_to_paper_list
    redirect_to paper_list_path(id: paper_list.id), notice: '論文リストが保存されました'
  rescue ActiveRecord::RecordNotFound => e
    redirect_to new_paper_list_path, alert: '指定したメンバーが見つかりませんでした'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_paper_list_path, alert: '論文リストの保存に失敗しました'
  end

  def edit
    @paper_list = current_user.paper_lists.find_by(id: params[:id]) ||
                  current_user.shared_paper_lists.find_by(id: params[:id])
  end

  def update
    paper_list = current_user.paper_lists.find_by(id: params[:id]) ||
                current_user.shared_paper_lists.find_by(id: params[:id])
    (redirect_to paper_lists_path, alert: '不正なパラメータです' and return) unless paper_list.present?
    paper_list = assign_params_to_paper_list(paper_list)
    redirect_to paper_list_path(id: paper_list.id), notice: '論文リストの編集が完了しました'
  rescue ActiveRecord::RecordNotFound => e
    redirect_to edit_paper_list_path(id: params[:id]), alert: '指定したメンバーが見つかりませんでした'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to edit_paper_list_path(id: params[:id]), alert: '論文リストの編集に失敗しました'
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
    paper_list = current_user.paper_lists.find_by(id: params[:id]) ||
                current_user.shared_paper_lists.find_by(id: params[:id])

    redirect_to :back, alert: "#{paper_list.title}にはこの論文がすでに登録されています" and return if paper_list.papers.find_by(id: paper.try(:id)).present?
    paper_list.papers << paper
    if paper.save && paper_list.save
      redirect_to :back, notice: "#{paper_list.title}に論文が登録されました"
    else
      redirect_to :back, alert: "#{paper_list.title}への論文の登録に失敗しました"
    end
  end

  def remove_paper
    relation = PaperPaperList.find_by(paper_list_id: remove_paper_params[:id], paper_id: remove_paper_params[:paper_id])
    paper = relation.paper
    paper_list = relation.paper_list
    if relation.destroy
      redirect_to paper_list_path(id: paper_list.id), notice: "#{paper_list.title}から論文#{': ' + paper.title if paper.title.present?}が削除されました"
    else
      redirect_to paper_list_path(id: paper_list.id), notice: "#{paper_list.title}からの論文#{': ' + paper.title if paper.title.present?}の削除に失敗しました"
    end
  end

  def search
    search_params
    @paper_lists = PaperList.search(search_params).page(params[:page]).per(20)
    @title = '検索結果'
  end

  private

  def assign_params_to_paper_list(paper_list=PaperList.new)
    ActiveRecord::Base.transaction do
      paper_list.assign_attributes(title: paper_list_params[:title], is_public: paper_list_params[:is_public])
      paper_list.user ||= current_user
      shared_users_params = paper_list_params[:shared_users_attributes].try(:values).try(:select) do |hash|
        hash[:_destroy] == 'false'
      end
      shared_users = shared_users_params.try(:map) do |user_params|
        user = User.find_by!(email: user_params[:email])
      end
      paper_list.shared_users = shared_users if shared_users.present?
      paper_list.save!
    end
    paper_list
  end

  def paper_list_params
    params.require(:paper_list).permit(:title, :is_public, shared_users_attributes:[:email, :_destroy])
  end

  def add_paper_params
    params.permit(:id, :pubmed_id, :date)
  end

  def remove_paper_params
    params.permit(:id, :paper_id)
  end

  def search_params
    params.permit(:sort, :keyword, :category, :username)
  end
end
