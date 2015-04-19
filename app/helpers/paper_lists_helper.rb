module PaperListsHelper
  def editable?(paper_list, user)
    !paper_list.history? && (paper_list.user == user || user.in?(paper_list.shared_users))
  end

  def options_addable_lists(paper, user)
    addable_lists = PaperList.by_user(user)
    if paper.id.present?
      addable_lists = addable_lists.joins("LEFT OUTER JOIN (SELECT * FROM paper_paper_lists WHERE paper_paper_lists.paper_id = #{paper.id})
                                          AS relations ON paper_lists.id = relations.paper_list_id").
                                    where("relations.id IS NULL")
    end
    ary = addable_lists.map do |pl|
      if pl.user == user
        label = pl.title
      else
        label = "#{pl.title}：#{pl.user.display_name}さんが作成"
      end
      [label, pl.id]
    end
    options_for_select(ary)
  end

  def paper_paper_list(paper, paper_list)
    PaperPaperList.find_by(paper: paper, paper_list: paper_list)
  end

  def read_date(paper, paper_list)
    paper_paper_list(paper, paper_list).try(:read_date)
  end

  def comment(paper, paper_list)
    paper_paper_list(paper, paper_list).try(:comment)
  end
end
