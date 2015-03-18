alpha.export 'routers.shared.PaperLists'

# @constructor
# @extends {alpha.mvc.Router}
class routers.shared.PaperLists extends alpha.mvc.Router

  routes:
    '/*p': 'shared'
    '/paper_lists': 'paperLists'
    '/paper_lists/:id': 'paperList'

  shared: (query) ->
    papersView = new views.shared.Papers
    papersView.decorate '.papers'
    papersHeaderView = new views.shared.PapersHeader(@parseQuery(location.search.slice(1)))
    papersHeaderView.decorate '.papers-header'

  paperLists: () ->
    ''

  paperList: (id) ->
    paperlistView = new views.paper_lists.PaperList
    paperlistView.decorate '.paper-list-detail'
