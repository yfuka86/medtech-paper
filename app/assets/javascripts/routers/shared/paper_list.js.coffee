alpha.export 'routers.shared.PaperList'

# @constructor
# @extends {alpha.mvc.Router}
class routers.shared.PaperList extends alpha.mvc.Router

  routes:
    '/*p': 'shared'

  # @param {?string} query
  shared: (query) ->
    paperListView = new views.shared.PaperList
    paperListView.decorate '.paper-list'
