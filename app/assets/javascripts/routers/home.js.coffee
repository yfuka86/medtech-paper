alpha.export 'routers.Home'

# @constructor
# @extends {alpha.mvc.Router}
class routers.Home extends alpha.mvc.Router

  routes:
    '(/)': 'index'

  index: ->
    homeView = new views.home.Main
    homeView.render '#home-container'
