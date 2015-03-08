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

  paperLists: () ->
    ''

  paperList: (id) ->
    paperlistView = new views.paper_lists.PaperList
    paperlistView.decorate '.paper-list-detail'
