class Api::Private::PaperListsController < Api::Private::BaseController

  def add_paper
    paper = Pubmed.fetch(add_paper_params[:pubmed_id])
    paper_list = current_user.paper_lists.find_by(id: params[:id]) ||
                current_user.shared_paper_lists.find_by(id: params[:id])

    error = "#{paper_list.title}にはこの論文がすでに登録されています" if paper_list.papers.find_by(id: paper.try(:id)).present?

    paper_list.papers << paper
    unless paper.save && paper_list.save
      error = "#{paper_list.title}への論文の登録に失敗しました"
    end

    if defined?(error) && error.is_a?(String)
      render_error(error)
    else
      render_success
    end
  end

  def remove_paper
    relation = PaperPaperList.find_by(paper_list_id: remove_paper_params[:id], paper_id: remove_paper_params[:paper_id])
    paper = relation.paper
    paper_list = relation.paper_list
    if relation.destroy
      render_success
    else
      render_error("#{paper_list.title}からの論文#{': ' + paper.title if paper.title.present?}の削除に失敗しました")
    end
  end

  private

  def add_paper_params
    params.permit(:id, :pubmed_id)
  end

  def remove_paper_params
    params.permit(:id, :paper_id)
  end
end