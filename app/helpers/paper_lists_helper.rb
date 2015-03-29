module PaperListsHelper
  def editable?(paper_list, user)
    paper_list.user == user || user.in?(paper_list.shared_users)
  end

  def addable_lists(paper, user)
    PaperList.by_user(user).
              joins("LEFT OUTER JOIN (SELECT * FROM paper_paper_lists WHERE paper_paper_lists.paper_id = #{paper.id})
                    AS relations ON paper_lists.id = relations.paper_list_id").
              where("relations.paper_id != #{paper.id}")
  end
end
